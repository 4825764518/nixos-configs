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
  sops.secrets.traefik-environment = {
    sopsFile = ../../secrets/firelink/traefik.yaml;
  };
  virtualisation.oci-containers.containers = {
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
        "${config.sops.secrets.traefik-traefik-config.path}:/traefik.yml:ro"
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
