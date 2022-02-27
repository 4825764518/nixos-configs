{ config, pkgs, ... }:

{
  imports = [ ../linux-desktop-common.nix ./hardware-configuration.nix ];

  networking.hostName = "stormveil";

  time.timeZone = "America/New_York";

  sops.secrets.stormveil-wireguard-privkey = {
    sopsFile = ../../secrets/stormveil/wireguard.yaml;
  };
  networking = {
    useDHCP = false;

    bridges.br0 = { interfaces = [ "enp40s0" "enp40s0d1" ]; };

    interfaces = {
      enp34s0 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "10.10.30.20";
          prefixLength = 24;
        }];
      };
      br0 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "10.10.31.20";
          prefixLength = 24;
        }];
      };
    };
    wireguard.interfaces = {
      wg-internal = {
        ips = [ "10.10.10.7/24" ];
        listenPort = 51820;
        privateKeyFile =
          "${config.sops.secrets.stormveil-wireguard-privkey.path}";
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

  sops.secrets.stormveil-kenzie-password = {
    sopsFile = ../../secrets/stormveil/passwords.yaml;
    neededForUsers = true;
  };
  users = {
    mutableUsers = false;

    users.kenzie = {
      createHome = true;
      extraGroups = [ "docker" "wheel" ];
      home = "/home/kenzie";
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
      passwordFile = "${config.sops.secrets.stormveil-kenzie-password.path}";
    };

    users.root = {
      openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
      password = null;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  services.openssh.enable = true;

  networking.firewall.enable = false;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
