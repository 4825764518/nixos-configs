{ config, lib, pkgs, ... }:

let
  containerHelpers = import ../container-helpers.nix {
    inherit lib;
    domain = "lan.kenzi.dev";
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
              main = "lan.kenzi.dev";
              sans = [ "*.lan.kenzi.dev" ];
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
  virtualisation.docker = { enable = true; };

  virtualisation.oci-containers.backend = "docker";

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

  sops.secrets.firelink-traefik-environment = {
    sopsFile = ../../secrets/firelink/containers.yaml;
  };
  virtualisation.oci-containers.containers = {
    jackett = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "jackett";
        port = 9117;
      };
      image = "ghcr.io/linuxserver/jackett:0.20.736";
      volumes = [
        "/opt/jackett:/config"
        "/hangar/torrent-downloads/blackhole:/downloads"
      ];
    };
    jellyfin = {
      autoStart = true;
      extraOptions = containerHelpers.containerLabelsSimple "jellyfin";
      image = "jellyfin/jellyfin:10.7.7";
      ports = [ "192.168.169.11:8096:8096" ];
      volumes = [
        "/opt/jellyfin/config:/config"
        "/opt/jellyfin/cache:/cache"
        "/hangar/torrent-downloads/media/tv:/media/tv:ro"
        "/hangar/torrent-downloads/media/movies:/media/movies:ro"
      ];
    };
    traefik = {
      autoStart = true;
      environmentFiles =
        [ "${config.sops.secrets.firelink-traefik-environment.path}" ];
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.http.routers.traefik.tls=true"
        "--label"
        "traefik.http.routers.traefik.service=api@internal"
      ];
      image = "traefik:v2.6.1";
      ports = [ "192.168.169.11:443:443" "192.168.171.11:443:443" ];
      volumes = [
        "${traefikStaticConfigPath}:/traefik.yml:ro"
        "/opt/traefik/acme.json:/acme.json"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
    qbittorrent = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
        WEBUI_PORT = "8082";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "qbittorrent";
        port = 8082;
      };
      image = "ghcr.io/linuxserver/qbittorrent:4.4.1";
      ports = [ "192.168.169.11:40744:40744" ];
      volumes = [
        "/opt/qbittorrent:/config"
        "/hangar/torrent-downloads:/hangar/torrent-downloads"
      ];
    };
    qbtsync = {
      autoStart = true;
      extraOptions = [ "--network=traefik-rproxy" ];
      image = "qbtsync:latest";
      volumes =
        [ "/opt/qbtsync/config.toml:/config.toml" "/opt/qbtsync/logs:/logs" ];
    };
    radarr = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "radarr";
        port = 7878;
      };
      image = "ghcr.io/linuxserver/radarr:4.0.5";
      volumes = [
        "/opt/radarr:/config"
        "/hangar:/hangar"
        "/hangar/torrent-downloads/movies:/downloads/staging"
      ];
    };
    sonarr = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "sonarr";
        port = 8989;
      };
      image = "ghcr.io/linuxserver/sonarr:3.0.7";
      volumes = [
        "/opt/sonarr:/config"
        "/hangar:/hangar"
        "/hangar/torrent-downloads/tv-sonarr:/downloads/staging"
      ];
    };
    syncthing = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "syncthing";
        port = 8384;
      };
      image = "ghcr.io/linuxserver/syncthing:1.19.1";
      ports = [ "22000:22000" ];
      volumes = [
        "/opt/syncthing/config:/config"
        "/hangar/torrent-downloads/staging:/staging"
      ];
    };
    vaultwarden = {
      autoStart = true;
      extraOptions = containerHelpers.containerLabels {
        name = "vaultwarden";
        hostname = "bitwarden";
      };
      image = "vaultwarden/server:1.24.0";
      volumes = [ "/opt/vaultwarden:/data" ];
    };
    whoami = {
      autoStart = true;
      extraOptions = containerHelpers.containerLabelsSimple "whoami";
      image = "traefik/whoami:v1.7.1";
    };
  };
}
