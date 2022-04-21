{ config, lib, pkgs, ... }:

{
  imports = [
    ../linux-common.nix
    ../linux-common-amd.nix
    ./containers.nix
    ./hardware-configuration.nix
    ./wireguard.nix
  ];

  networking.hostName = "ainsel";

  boot.supportedFilesystems = [ "zfs" ];

  networking = {
    hostId = "177818d9";
    useDHCP = false;

    networkmanager = {
      enable = false;
      unmanaged = [ "enp7s0" ];
    };

    interfaces = {
      enp7s0 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "65.21.233.174";
          prefixLength = 26;
        }];
        ipv6.addresses = [{
          address = "2a01:4f9:6a:206b::1";
          prefixLength = 64;
        }];
      };
    };

    defaultGateway = "65.21.233.129";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp7s0";
    };
    nameservers = [ "1.1.1.1" ];
  };

  time.timeZone = "Europe/Helsinki";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users = {
    groups.containers = {
      gid = 2000;
      members = [ "containers" ];
    };

    users.dragonkin = {
      isNormalUser = true;
      home = "/home/dragonkin";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
      shell = pkgs.zsh;
    };

    users.containers = {
      isSystemUser = true;
      uid = 2000;
      group = "containers";
    };

    users.root = {
      password = null;
      shell = pkgs.zsh;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;

    users.dragonkin = import ../../home/home-linux-server.nix;
    users.root = import ../../home/home-linux-server.nix;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    challengeResponseAuthentication = false;
  };

  sops.secrets.ainsel-restic-b2-environment = {
    sopsFile = ../../secrets/ainsel/passwords.yaml;
  };
  sops.secrets.ainsel-restic-b2-password = {
    sopsFile = ../../secrets/ainsel/passwords.yaml;
  };
  services.restic.backups = {
    b2Backup = {
      environmentFile =
        "${config.sops.secrets.ainsel-restic-b2-environment.path}";
      initialize = true;
      passwordFile = "${config.sops.secrets.ainsel-restic-b2-password.path}";
      paths = [
        "/home"
        "/root"
        "/storage/containers/gitlab/config"
        "/storage/containers/gitlab/data/backups"
        "/storage/containers/qbittorrent"
        "/storage/containers/qbtsync"
        "/storage/containers/syncthing"
        "/storage/containers/thelounge"
        "/storage/containers/torrent-proxy"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 100"
      ];
      extraOptions = [ "verbose=1" ];
      repository = "b2:restic-ainsel:/";
      timerConfig = { OnCalendar = "daily"; };
    };
  };

  systemd.services."restic-backups-b2Backup".preStart = ''
    rm -fv /storage/containers/gitlab/data/backups/*
    echo "Removed old dumps"
    ${config.virtualisation.docker.package}/bin/docker exec gitlab gitlab-backup create BACKUP=dump GZIP_RSYNCABLE=yes
    echo "Finished gitlab dump"
  '';

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 443 22000 23843 51820 ];
  networking.firewall.allowedUDPPorts = [ 22 23843 51820 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
