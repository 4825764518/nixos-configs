{ config, pkgs, ... }:

{
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

  sops.secrets.firelink-traefik-config = {
    sopsFile = ../../secrets/firelink/containers.yaml;
  };
  sops.secrets.firelink-traefik-environment = {
    sopsFile = ../../secrets/firelink/traefik.yaml;
  };
  virtualisation.oci-containers.containers = {
    jackett = {
      autoStart = true;
      environment = {
        PUID = "1000";
        PGID = "1000";
      };
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.enable=true"
        "--label"
        "traefik.http.routers.jackett.entryPoints=websecure"
        "--label"
        "traefik.http.routers.jackett.rule=Host(`jackett.lan.kenzi.dev`)"
        "--label"
        "traefik.http.services.jackett.loadbalancer.server.port=9117"
      ];
      image = "linuxserver/jackett:0.20.629";
      volumes = [
        "/opt/jackett:/config"
        "/hangar/torrent-downloads/blackhole:/downloads"
      ];
    };
    jellyfin = {
      autoStart = true;
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.enable=true"
        "--label"
        "traefik.http.routers.jellyfin.entryPoints=websecure"
        "--label"
        "traefik.http.routers.jellyfin.rule=Host(`jellyfin.lan.kenzi.dev`)"
      ];
      image = "jellyfin/jellyfin:10.7.7";
      ports = [ "10.10.30.11:8096:8096" ];
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
      image = "traefik:v2.3";
      ports = [ "10.10.30.11:443:443" ];
      volumes = [
        "${config.sops.secrets.traefik-traefik-config.path}:/traefik.yml:ro"
        "/opt/traefik/acme.json:/acme.json"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
    };
    qbittorrent = {
      autoStart = true;
      environment = { WEBUI_PORT = "8082"; };
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.enable=true"
        "--label"
        "traefik.http.routers.qbittorrent.entryPoints=websecure"
        "--label"
        "traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.lan.kenzi.dev`)"
        "--label"
        "traefik.http.services.qbittorrent.loadbalancer.server.port=8082"
      ];
      image =
        "ghcr.io/linuxserver/qbittorrent:14.3.8.99202108291924-7418-9392ce436ubuntu20.04.1-ls152";
      ports = [ "10.10.30.11:40744:40744" ];
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
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.enable=true"
        "--label"
        "traefik.http.routers.radarr.entryPoints=websecure"
        "--label"
        "traefik.http.routers.radarr.rule=Host(`radarr.lan.kenzi.dev`)"
        "--label"
        "traefik.http.services.radarr.loadbalancer.server.port=7878"
      ];
      image = "linuxserver/radarr:4.0.4";
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
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.enable=true"
        "--label"
        "traefik.http.routers.sonarr.entryPoints=websecure"
        "--label"
        "traefik.http.routers.sonarr.rule=Host(`sonarr.lan.kenzi.dev`)"
        "--label"
        "traefik.http.services.sonarr.loadbalancer.server.port=8989"
      ];
      image = "linuxserver/sonarr:develop-alpine-3.0.6.1470-ls18";
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
      extraOptions = [
        "--network=traefik-rproxy"
        "--label"
        "traefik.enable=true"
        "--label"
        "traefik.http.routers.syncthing.entryPoints=websecure"
        "--label"
        "traefik.http.routers.syncthing.rule=Host(`syncthing.lan.kenzi.dev`)"
        "--label"
        "traefik.http.services.syncthing.loadbalancer.server.port=8384"
      ];
      image = "ghcr.io/linuxserver/syncthing:v1.19.0-ls68";
      ports = [ "22000:22000" ];
      volumes = [
        "/opt/syncthing/config:/config"
        "/hangar/torrent-downloads/staging:/staging"
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
