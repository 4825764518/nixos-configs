{ config, pkgs, ... }:

{
  imports = [
    ../linux-common.nix
    ../../apps/common.nix
    ../../apps/nix.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "stormveil";

  time.timeZone = "America/New_York";

  networking = {
    useDHCP = false;

    bridges.br0 = { interfaces = [ "enp40s0" "enp40s0d1" ]; };

    interfaces = {
      enp34s0 = {
        ipv4.addresses = [{
          address = "10.10.30.20";
          prefixLength = 24;
        }];
      };
      br0 = {
        ipv4.addresses = [{
          address = "10.10.31.20";
          prefixLength = 24;
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
      extraGroups = [ "wheel" ];
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.openssh.enable = true;

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
