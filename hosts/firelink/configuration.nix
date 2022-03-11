# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ../linux-common.nix
    ./hardware-configuration.nix
    ./containers.nix
  ];

  networking.hostName = "firelink";
  time.timeZone = "America/New_York";

  sops.secrets.firelink-wireguard-privkey = {
    sopsFile = ../../secrets/firelink/wireguard.yaml;
  };
  networking = {
    useDHCP = false;
    interfaces.enp6s18 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "10.10.30.11";
        prefixLength = 24;
      }];
    };
    interfaces.enp6s19 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "10.10.31.11";
        prefixLength = 24;
      }];
    };
    wireguard.interfaces = {
      wg-internal = {
        ips = [ "10.10.10.4/24" ];
        listenPort = 51820;
        privateKeyFile =
          "${config.sops.secrets.firelink-wireguard-privkey.path}";
        peers = [{
          publicKey = "Mo1wqAe5SNixIikRSlVY9DpT5Nz19mZenWym3voa0TM=";
          allowedIPs = [ "10.10.10.0/24" "10.10.40.0/24" ];
          endpoint = "192.99.14.203:51820";
          persistentKeepalive = 25;
        }];
      };
    };

    defaultGateway = "10.10.30.1";
    nameservers = [ "10.10.30.1" ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users = {
    users.shrinekeeper = {
      isNormalUser = true;
      home = "/home/shrinekeeper";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
      shell = pkgs.zsh;
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

    users.shrinekeeper = import ../../home/home-linux-server.nix;
    users.root = import ../../home/home-linux-server.nix;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    challengeResponseAuthentication = false;
  };

  networking.firewall.enable = false;

  sops.secrets.firelink-restic-password = {
    sopsFile = ../../secrets/firelink/passwords.yaml;
  };
  sops.secrets.firelink-restic-b2-environment = {
    sopsFile = ../../secrets/firelink/passwords.yaml;
  };
  sops.secrets.firelink-restic-b2-password = {
    sopsFile = ../../secrets/firelink/passwords.yaml;
  };
  services.restic.backups = {
    lanBackup = {
      initialize = true;
      passwordFile = "${config.sops.secrets.firelink-restic-password.path}";
      paths = [ "/home" "/opt" "/root" "/var" ];
      extraBackupArgs = [ "--exclude=/opt/containerd" ];
      pruneOpts = [
        "--keep-daily 30"
        "--keep-weekly 12"
        "--keep-monthly 36"
        "--keep-yearly 100"
      ];
      repository =
        "sftp:restic@10.10.31.10:/hangar/restic-backups/firelink-backups";
      timerConfig = { OnCalendar = "daily"; };
    };
    b2Backup = {
      environmentFile =
        "${config.sops.secrets.firelink-restic-b2-environment.path}";
      initialize = true;
      passwordFile = "${config.sops.secrets.firelink-restic-b2-password.path}";
      paths = [ "/home" "/root" "/opt/vaultwarden" ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 100"
      ];
      repository = "b2:restic-firelink:/";
      timerConfig = { OnCalendar = "daily"; };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
