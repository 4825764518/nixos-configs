{ config, pkgs, ... }:

{
  imports = [ ../linux-common.nix ./hardware-configuration.nix ];

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
      };
    };

    defaultGateway = "65.108.197.1";
    nameservers = [ "1.1.1.1" ];
  };

  time.timeZone = "Europe/Helsinki";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users = {
    users.esgar = {
      isNormalUser = true;
      home = "/home/esgar";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
      shell = pkgs.zsh;
    };

    users.root = {
      password = null;
      shell = pkgs.zsh;
    };
  };

  services.openssh.enable = true;

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
