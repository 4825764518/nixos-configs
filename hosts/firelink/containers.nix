{ config, pkgs, ... }:

let
  traefikStaticConfigPath = builtins.toFile "traefik.yml" (builtins.toJSON {
    entryPoints.websecure = {
      address = ":443";
      http.tls = {
        certResolver = "le";
        domains = [{
          main = "lan.kenzi.dev";
          sans = [ "*.lan.kenzi.dev" ];
        }];
      };
    };
    certificatesResolvers.le.acme = {
      email = "autismal69@protonmail.com";
      storage = "acme.json";
      dnsChallenge = {
        provider = "cloudflare";
        delayBeforeCheck = 15;
      };
    };
    providers.docker = { exposedByDefault = false; };
  });
in {
  virtualisation.docker.enable = true;

  # https://www.breakds.org/post/declarative-docker-in-nixos/
  systemd.services.init-traefik-network = {
    description = "Create the network bridge traefik-rproxy.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    path = [ config.virtualisation.docker.package ];
    script = ''
      # Put a true at the end to prevent getting non-zero return code, which will
      # crash the whole service.
      check=$(docker network ls | grep "traefik-rproxy" || true)
      if [ -z "$check" ]; then
        docker network create traefik-rproxy
      else
        echo "traefik-rproxy already exists in docker"
      fi
    '';
  };

  sops.secrets.traefik-environment = {
    sopsFile = ../../secrets/firelink/traefik.yaml;
  };
  virtualisation.oci-containers.containers = {
    traefik = {
      autoStart = true;
      environmentFiles = [ "${config.sops.secrets.traefik-environment.path}" ];
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.http.routers.traefik.tls=true"
        "--label"
        "traefik.http.routers.traefik.service=api@internal"
      ];
      image = "traefik:v2.3";
      ports = [ "10.10.30.11:443:443" ];
      volumes = [
        "${traefikStaticConfigPath}:/traefik.yml:ro"
        "/opt/traefik/acme.json:/acme.json"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
    vaultwarden = {
      autoStart = true;
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.enable=true"
        "--label"
        "traefik.http.routers.vaultwarden.entryPoints=websecure"
        "--label"
        "traefik.http.routers.vaultwarden.rule=Host(`bitwarden.lan.kenzi.dev`)"
      ];
      image = "vaultwarden/server:1.24.0";
      volumes = [ "/opt/vaultwarden:/data" ];
    };
    whoami = {
      autoStart = true;
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.enable=true"
        "--label"
        "traefik.http.routers.whoami.entryPoints=websecure"
        "--label"
        "traefik.http.routers.whoami.rule=Host(`whoami.lan.kenzi.dev`)"
      ];
      image = "traefik/whoami:v1.7.1";
    };
  };
}
