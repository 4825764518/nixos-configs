{ config, pkgs, ... }:

let
  traefikStaticConfigPath = builtins.toFile "traefik.yml" (builtins.toJSON {
    entryPoints = {
      websecure = {
        address = ":443";
        http = {
          tls = {
            certResolver = "le";
            domains = [{
              main = "kenzi.dev";
              sans = [ "*.kenzi.dev" ];
            }];
          };
        };
      };
      wgsecure = {
        address = ":4443";
        http = {
          tls = {
            certResolver = "le";
            domains = [{
              main = "leyndell.kenzi.dev";
              sans = [ "*.leyndell.kenzi.dev" ];
            }];
          };
        };
      };
    };
    certificatesResolvers = {
      le = {
        acme = {
          email = "autismal69@protonmail.com";
          storage = "acme.json";
          dnsChallenge = {
            provider = "cloudflare";
            delayBeforeCheck = 15;
          };
        };
      };
    };
    providers = { docker = { exposedByDefault = false; }; };
  });
in {
  virtualisation.docker.enable = true;

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
          ${dockercli} network create traefik-rproxy
        else
          echo "traefik-rproxy already exists in docker"
        fi
      '';
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
      ports = [ "65.108.197.14:443:443" "192.168.172.10:443:4443" ];
      volumes = [
        "${traefikStaticConfigPath}:/traefik.yml:ro"
        "/opt/containers/traefik/acme.json:/acme.json"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
    synapse-postgres = {
      autoStart = true;
      environmentFiles =
        [ "${config.sops.secrets.leyndell-synapse-postgres-environment.path}" ];
      extraOptions = [ "--network=traefik-rproxy" ];
      image = "postgres:12";
      volumes =
        [ "/opt/containers/synapse-postgres/data:/var/lib/postgresql/data" ];
    };
    synapse = {
      autoStart = true;
      dependsOn = [ "synapse-postgres" ];
      environmentFiles =
        [ "${config.sops.secrets.leyndell-synapse-environment.path}" ];
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.enable=true"
        "--label"
        "traefik.http.services.synapse.loadbalancer.server.port=8008"
        "--label"
        "traefik.http.routers.synapse.entryPoints=websecure"
        "--label"
        "traefik.http.routers.synapse.rule=Host(`matrix.kenzi.dev`)"
      ];
      volumes = [ "/opt/containers/synapse/files:/data" ];
      image = "matrixdotorg/synapse:v1.56.0";
    };
  };
}
