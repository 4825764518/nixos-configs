{ config, lib, pkgs, ... }:

let
  containerHelpers = import ../container-helpers.nix {
    inherit lib;
    domain = "media.kenzi.dev";
    entryPoint = "websecure";
    network = "traefik-rproxy-media";
  };
  traefikStaticConfigPath = builtins.toFile "traefik.yml" (builtins.toJSON {
    entryPoints.websecure = {
      address = ":443";
      http.tls = {
        certResolver = "le";
        domains = [{
          main = "media.kenzi.dev";
          sans = [ "*.media.kenzi.dev" ];
        }];
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
    providers = { docker = { exposedByDefault = false; }; };
  });
in {
  virtualisation.docker.enable = true;

  virtualisation.oci-containers.backend = "docker";

  # https://www.breakds.org/post/declarative-docker-in-nixos/
  systemd.services.init-traefik-media-network = {
    description = "Create the network bridge traefik-rproxy-media.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    script =
      let dockercli = "${config.virtualisation.docker.package}/bin/docker";
      in ''
        # Put a true at the end to prevent getting non-zero return code, which will
        # crash the whole service.
        check=$(${dockercli} network ls | grep "traefik-rproxy-media" || true)
        if [ -z "$check" ]; then
          ${dockercli} network create traefik-rproxy-media
        else
          echo "traefik-rproxy-media already exists in docker"
        fi
      '';
  };

  sops.secrets.ainsel-traefik-environment = {
    sopsFile = ../../secrets/ainsel/containers.yaml;
  };
  virtualisation.oci-containers.containers = {
    media-bazarr = {
      autoStart = true;
      environment = {
        PUID = "2000";
        PGID = "2000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "bazarr";
        port = 6767;
      };
      image = "ghcr.io/linuxserver/bazarr:development-version-v1.0.5-beta.28";
      volumes = [
        "/storage/media/containers/bazarr/config:/config"
        "/storage/media/libraries/movies:/movies"
        "/storage/media/libraries/tv:/tv"
      ];
    };
    media-overseerr = {
      autoStart = true;
      environment = {
        PUID = "2000";
        PGID = "2000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "overseerr";
        port = 5055;
      };
      image = "ghcr.io/linuxserver/overseerr:1.29.1";
      volumes = [ "/storage/media/containers/overseerr/config:/config" ];
    };
    media-plex = {
      autoStart = true;
      environment = {
        PUID = "2000";
        PGID = "2000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "plex";
        port = 32400;
      };
      image = "ghcr.io/linuxserver/plex:1.27.0";
      volumes = [
        "/storage/media/containers/plex/config:/config"
        "/storage/media/libraries/movies:/movies"
        "/storage/media/libraries/tv:/tv"
      ];
    };
    media-prowlarr = {
      autoStart = true;
      environment = {
        PUID = "2000";
        PGID = "2000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "prowlarr";
        port = 9696;
      };
      image = "ghcr.io/linuxserver/prowlarr:nightly-version-0.4.0.1816";
      volumes = [ "/storage/media/containers/prowlarr/config:/config" ];
    };
    media-qbittorrent = {
      autoStart = true;
      environment = {
        PUID = "2000";
        PGID = "2000";
        WEBUI_PORT = "8082";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "media-qbittorrent";
        hostname = "qbittorrent";
        port = 8082;
      };
      # Downgraded from 4.4.1 due to 
      # https://github.com/qbittorrent/qBittorrent/issues/16095
      # Tracker information being wiped out by torrents saved into BT_Backup breaks qbtsync
      image = "ghcr.io/linuxserver/qbittorrent:14.3.9";
      ports = [ "65.21.233.174:23844:23844" ];
      volumes = [
        "/storage/media/containers/qbittorrent/config:/config"
        "/storage/media/downloads:/downloads"
      ];
    };
    media-radarr = {
      autoStart = true;
      environment = {
        PUID = "2000";
        PGID = "2000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "radarr";
        port = 7878;
      };
      image = "ghcr.io/linuxserver/radarr:4.0.5";
      volumes = [
        "/storage/media/containers/radarr/config:/config"
        "/storage/media/downloads:/downloads"
        "/storage/media/libraries/movies:/movies"
      ];
    };
    media-sonarr = {
      autoStart = true;
      environment = {
        PUID = "2000";
        PGID = "2000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "sonarr";
        port = 8989;
      };
      image = "ghcr.io/linuxserver/sonarr:3.0.7";
      volumes = [
        "/storage/media/containers/sonarr/config:/config"
        "/storage/media/downloads:/downloads"
        "/storage/media/libraries/tv:/tv"
      ];
    };
    media-traefik = {
      autoStart = true;
      environmentFiles =
        [ "${config.sops.secrets.ainsel-traefik-environment.path}" ];
      extraOptions = [
        "--network=traefik-rproxy-media"
        "--label"
        "traefik.http.routers.traefik.tls=true"
        "--label"
        "traefik.http.routers.traefik.service=api@internal"
      ];
      image = "traefik:v2.6.1";
      ports = [ "192.168.173.20:443:443" ];
      volumes = [
        "${traefikStaticConfigPath}:/traefik.yml:ro"
        "/storage/media/containers/traefik/acme.json:/acme.json"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
    media-whoami = {
      autoStart = true;
      extraOptions = containerHelpers.containerLabels {
        name = "media-whoami";
        hostname = "whoami";
      };
      image = "traefik/whoami:v1.7.1";
    };
  };
}
