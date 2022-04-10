{ config, lib, pkgs, ... }:

let
  containerHelpers = import ../container-helpers.nix {
    inherit lib;
    domain = "ainsel.kenzi.dev";
    entryPoint = "websecure";
    network = "traefik-rproxy";
  };
  traefikStaticConfigPath = builtins.toFile "traefik.yml" (builtins.toJSON {
    entryPoints = {
      websecure = {
        address = ":443";
        http = {
          tls = {
            certResolver = "le";
            domains = [{
              main = "ainsel.kenzi.dev";
              sans = [ "*.ainsel.kenzi.dev" ];
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

  sops.secrets.ainsel-minio-environment = {
    sopsFile = ../../secrets/ainsel/containers.yaml;
  };
  sops.secrets.ainsel-traefik-environment = {
    sopsFile = ../../secrets/ainsel/containers.yaml;
  };
  virtualisation.oci-containers.containers = {
    minio = {
      autoStart = true;
      cmd = [ "server" "/data" "--console-address" ":9001" ];
      environmentFiles =
        [ "${config.sops.secrets.ainsel-minio-environment.path}" ];
      extraOptions = [ "--network=traefik-rproxy" ]
        ++ containerHelpers.traefikLabels {
          name = "s3";
          port = 9000;
          service = true;
        } ++ containerHelpers.traefikLabels {
          name = "minio";
          port = 9001;
          service = true;
        };
      image = "minio/minio:RELEASE.2022-04-09T15-09-52Z";
      volumes = [ "/storage/minio/data:/data" ];
    };
    traefik = {
      autoStart = true;
      environmentFiles =
        [ "${config.sops.secrets.ainsel-traefik-environment.path}" ];
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.http.routers.traefik.tls=true"
        "--label"
        "traefik.http.routers.traefik.service=api@internal"
      ];
      image = "traefik:v2.6.1";
      ports = [ "192.168.172.20:443:443" ];
      volumes = [
        "${traefikStaticConfigPath}:/traefik.yml:ro"
        "/opt/containers/traefik/acme.json:/acme.json"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
    whoami = {
      autoStart = true;
      extraOptions = containerHelpers.containerLabelsSimple "whoami";
      image = "traefik/whoami:v1.7.1";
    };
  };
}
