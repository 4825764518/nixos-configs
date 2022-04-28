{ config, lib, pkgs, ... }:

let
  containerHelpers = import ../container-helpers.nix {
    inherit lib;
    domain = "kenzi.dev";
    entryPoint = "websecure";
    network = "traefik-rproxy";
  };
  containerHelpersWireguard = import ../container-helpers.nix {
    inherit lib;
    domain = "leyndell.kenzi.dev";
    entryPoint = "wgsecure";
    network = "traefik-rproxy";
  };
  traefikStaticConfigPath = builtins.toFile "traefik.yml" (builtins.toJSON {
    entryPoints = {
      websecure = {
        address = ":443";
        http.tls = {
          certResolver = "le";
          domains = [{
            main = "kenzi.dev";
            sans = [ "*.kenzi.dev" ];
          }];
        };
      };
      wgsecure = {
        address = ":4443";
        http.tls = {
          certResolver = "le";
          domains = [{
            main = "leyndell.kenzi.dev";
            sans = [ "*.leyndell.kenzi.dev" ];
          }];
        };
      };
    };
    certificatesResolvers.le.acme = {
      email = "admin@kenzi.dev";
      storage = "acme.json";
      dnsChallenge = {
        provider = "cloudflare";
        delayBeforeCheck = 15;
      };
    };
    providers = {
      docker = { exposedByDefault = false; };
      file.filename = "/traefik-dynamic.yml";
    };
  });
  traefikDynamicConfigPath = builtins.toFile "traefik-dynamic.yml"
    (builtins.toJSON {
      tls.options.default = {
        minVersion = "VersionTLS13";
        sniStrict = true;
      };
    });
in {
  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = "--config-file=${
      pkgs.writeText "daemon.json" (builtins.toJSON {
        ipv6 = true;
        fixed-cidr-v6 = "2a01:4f9:1a:991f::/80";
      })
    }";

  # https://www.breakds.org/post/declarative-docker-in-nixos/
  systemd.services.init-traefik-network = {
    description = "Create the network bridge traefik-rproxy.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    script =
      let dockercli = "${config.virtualisation.docker.package}/bin/docker";
      in ''
        # Put a true at the end to prevent getting non-zero return code, which will
        # crash the whole service.
        check=$(${dockercli} network ls | grep "traefik-rproxy" || true)
        if [ -z "$check" ]; then
          ${dockercli} network create --ipv6 --subnet fd70:1c24:ed13::/48 traefik-rproxy
        else
          echo "traefik-rproxy already exists in docker"
        fi
      '';
  };

  sops.secrets.leyndell-synapse-postgres-backup-environment = {
    sopsFile = ../../secrets/leyndell/containers.yaml;
  };
  sops.secrets.leyndell-synapse-postgres-environment = {
    sopsFile = ../../secrets/leyndell/containers.yaml;
  };
  sops.secrets.leyndell-synapse-environment = {
    sopsFile = ../../secrets/leyndell/containers.yaml;
  };
  sops.secrets.leyndell-traefik-environment = {
    sopsFile = ../../secrets/leyndell/containers.yaml;
  };
  virtualisation.oci-containers.containers = {
    traefik = {
      autoStart = true;
      environmentFiles =
        [ "${config.sops.secrets.leyndell-traefik-environment.path}" ];
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.http.routers.traefik.tls=true"
        "--label"
        "traefik.http.routers.traefik.service=api@internal"
      ];
      image = "traefik:v2.6.1";
      ports = [
        "65.108.197.14:443:443"
        "[2a01:4f9:1a:991f::]:443:443"
        "192.168.172.10:443:4443"
        "[fdc3:62d8:4c3a:0010::]:443:4443"
      ];
      volumes = [
        "${traefikStaticConfigPath}:/traefik.yml:ro"
        "${traefikDynamicConfigPath}:/traefik-dynamic.yml:ro"
        "/opt/containers/traefik/acme.json:/acme.json"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
    synapse-postgres = {
      autoStart = true;
      environmentFiles =
        [ "${config.sops.secrets.leyndell-synapse-postgres-environment.path}" ];
      extraOptions = [ "--network=traefik-rproxy" ];
      image = "postgres:14";
      volumes = [
        "/opt/containers/synapse-postgres/data:/var/lib/postgresql/data"
        "/opt/containers/synapse-postgres/dump:/dump"
      ];
    };
    synapse = {
      autoStart = true;
      dependsOn = [ "synapse-postgres" ];
      environmentFiles =
        [ "${config.sops.secrets.leyndell-synapse-environment.path}" ];
      extraOptions = containerHelpers.containerLabels {
        name = "synapse";
        hostname = "matrix";
        port = 8008;
      };
      volumes = [ "/opt/containers/synapse/files:/data" ];
      image = "matrixdotorg/synapse:v1.57.1";
    };
    whoami = {
      autoStart = true;
      extraOptions = containerHelpersWireguard.containerLabelsSimple "whoami";
      image = "traefik/whoami:v1.7.1";
    };
  };
}
