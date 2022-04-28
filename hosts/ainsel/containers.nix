{ config, lib, pkgs, ... }:

let
  containerHelpers = import ../container-helpers.nix {
    inherit lib;
    domain = "ainsel.kenzi.dev";
    entryPoint = "websecure";
    network = "traefik-rproxy";
  };
  traefikStaticConfigPath = builtins.toFile "traefik.yml" (builtins.toJSON {
    entryPoints.websecure = {
      address = ":443";
      http.tls = {
        certResolver = "le";
        domains = [{
          main = "ainsel.kenzi.dev";
          sans = [ "*.ainsel.kenzi.dev" ];
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
    gitlab = {
      autoStart = true;
      environment = {
        GITLAB_OMNIBUS_CONFIG = ''
          external_url 'https://gitlab.ainsel.kenzi.dev';
          gitlab_rails['smtp_enable'] = false;
          gitlab_rails['gitlab_email_enabled'] = false;
          nginx['listen_port'] = 80;
          nginx['listen_https'] = false;
          nginx['proxy_set_headers'] = {
            "X-Forwarded-Proto" => "https",
            "X-Forwarded-Ssl" => "on",
          };
          nginx['real_ip_header'] = 'X-Real-Ip';
          nginx['real_ip_recursive'] = 'on';
        '';
      };
      extraOptions = [ "--network=traefik-rproxy" ]
        ++ containerHelpers.traefikLabels {
          name = "gitlab";
          port = 80;
        };
      image = "gitlab/gitlab-ce:14.9.3-ce.0";
      ports = [ "192.168.172.20:222:22" ];
      volumes = [
        "/storage/containers/gitlab/config:/etc/gitlab"
        "/storage/containers/gitlab/logs:/var/log/gitlab"
        "/storage/containers/gitlab/data:/var/opt/gitlab"
      ];
    };
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
      volumes = [ "/storage/containers/minio/data:/data" ];
    };
    qbittorrent = {
      autoStart = true;
      dependsOn = [ "torrent-proxy" ];
      environment = {
        PUID = "2000";
        PGID = "2000";
        WEBUI_PORT = "8082";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "qbittorrent";
        port = 8082;
      };
      # Downgraded from 4.4.1 due to 
      # https://github.com/qbittorrent/qBittorrent/issues/16095
      # Tracker information being wiped out by torrents saved into BT_Backup breaks qbtsync
      image = "ghcr.io/linuxserver/qbittorrent:14.3.9";
      ports = [ "65.21.233.174:23843:23843" ];
      volumes = [
        "/storage/containers/qbittorrent/config:/config"
        "/storage/downloads:/downloads"
      ];
    };
    qbtsync = {
      autoStart = true;
      dependsOn = [ "qbittorrent" ];
      extraOptions = containerHelpers.containerLabels {
        name = "qbtsync";
        port = 8080;
      };
      image = "qbtsync:latest";
      volumes = [
        "/storage/containers/qbtsync/config.toml:/config.toml"
        "/storage/containers/qbittorrent/config/qBittorrent/BT_backup:/torrents"
      ];
    };
    syncthing = {
      autoStart = true;
      environment = {
        PUID = "2000";
        PGID = "2000";
      };
      extraOptions = containerHelpers.containerLabels {
        name = "syncthing";
        port = 8384;
      };
      image = "ghcr.io/linuxserver/syncthing:1.19.1";
      ports = [ "192.168.172.20:22000:22000" ];
      volumes = [
        "/storage/containers/syncthing/config:/config"
        "/storage/downloads/staging:/staging"
      ];
    };
    thelounge = {
      autoStart = true;
      extraOptions = containerHelpers.containerLabels {
        name = "thelounge";
        hostname = "irc";
      };
      image = "thelounge/thelounge:4.3.1";
      volumes = [ "/storage/containers/thelounge:/var/opt/thelounge" ];
    };
    torrent-proxy = {
      autoStart = true;
      extraOptions = containerHelpers.containerLabels {
        name = "torrent-proxy";
        hostname = "tproxy";
      };
      image = "torrent-proxy:latest";
      volumes = [
        "/storage/containers/torrent-proxy/config.json:/app/config.json"
        "/storage/containers/torrent-proxy/db:/app/db"
      ];
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
