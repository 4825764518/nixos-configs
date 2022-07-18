{ config, pkgs, ... }:

let
  postgresDumpScript = name: ''
    rm -fv /opt/containers/synapse-postgres/dump/${name}/synapse-postgres-dump.sql*
    echo "Removed old dumps"
    ${config.virtualisation.docker.package}/bin/docker exec synapse-postgres pg_dumpall --username=synapse --file=/dump/${name}/synapse-postgres-dump.sql
    echo "Finished postgres dump, compressing with zstd"
    ${pkgs.zstd}/bin/zstd --compress -9 --rm --threads=0 --rsyncable /opt/containers/synapse-postgres/dump/${name}/synapse-postgres-dump.sql 
    echo "Finished compressing postgres dump"
  '';
in {
  imports = [
    ../linux-common.nix
    ../linux-common-amd.nix
    ./containers.nix
    ./hardware-configuration.nix
    ./wireguard.nix
    ../xmrig.nix
  ];

  networking.hostName = "leyndell";

  networking = {
    useDHCP = false;

    networkmanager = {
      enable = false;
      unmanaged = [ "enp35s0" ];
    };

    interfaces = {
      enp35s0 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "65.108.197.14";
          prefixLength = 26;
        }];
        ipv6.addresses = [{
          address = "2a01:4f9:1a:991f::";
          prefixLength = 64;
        }];
      };
    };

    defaultGateway = "65.108.197.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp35s0";
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
    groups = {
      synapse = {
        gid = 2000;
        members = [ "synapse" ];
      };
    };

    users = {
      esgar = {
        isNormalUser = true;
        home = "/home/esgar";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
        shell = pkgs.zsh;
      };

      root = {
        password = null;
        shell = pkgs.zsh;
      };

      synapse = {
        isSystemUser = true;
        group = "synapse";
        uid = 2000;
      };
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;

    users.esgar = import ../../home/home-linux-server.nix;
    users.root = import ../../home/home-linux-server.nix;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    challengeResponseAuthentication = false;
  };

  sops.secrets.leyndell-restic-ainsel-s3-environment = {
    sopsFile = ../../secrets/leyndell/passwords.yaml;
  };
  sops.secrets.leyndell-restic-ainsel-s3-password = {
    sopsFile = ../../secrets/leyndell/passwords.yaml;
  };
  sops.secrets.leyndell-restic-b2-environment = {
    sopsFile = ../../secrets/leyndell/passwords.yaml;
  };
  sops.secrets.leyndell-restic-b2-password = {
    sopsFile = ../../secrets/leyndell/passwords.yaml;
  };
  services.restic.backups = {
    ainselBackup = {
      environmentFile =
        "${config.sops.secrets.leyndell-restic-ainsel-s3-environment.path}";
      initialize = true;
      passwordFile =
        "${config.sops.secrets.leyndell-restic-ainsel-s3-password.path}";
      paths = [
        "/home"
        "/root"
        "/opt/containers/synapse"
        "/opt/containers/synapse-postgres/dump/ainsel"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 100"
      ];
      extraOptions = [ "verbose=1" ];
      repository = "s3:https://s3.ainsel.kenzi.dev/leyndell-backups";
      timerConfig = { OnCalendar = "daily"; };
    };
    b2Backup = {
      environmentFile =
        "${config.sops.secrets.leyndell-restic-b2-environment.path}";
      initialize = true;
      passwordFile = "${config.sops.secrets.leyndell-restic-b2-password.path}";
      paths = [
        "/home"
        "/root"
        "/opt/containers/synapse"
        "/opt/containers/synapse-postgres/dump/b2"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 100"
      ];
      extraOptions = [ "verbose=1" ];
      repository = "b2:restic-leyndell:/";
      timerConfig = { OnCalendar = "daily"; };
    };
  };

  systemd.services."restic-backups-ainselBackup".preStart =
    postgresDumpScript "ainsel";
  systemd.services."restic-backups-b2Backup".preStart = postgresDumpScript "b2";

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 443 51820 ];
  networking.firewall.allowedUDPPorts = [ 22 51820 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
