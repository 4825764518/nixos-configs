{ config, pkgs, ... }:

{
  imports = [ ../linux-desktop-common.nix ./hardware-configuration.nix ];

  networking.hostName = "staging";

  time.timeZone = "America/New_York";

  networking = {
    useDHCP = false;

    networkmanager = {
      enable = false;
      unmanaged = [ "enp6s18" ];
    };

    interfaces = {
      enp6s18 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "10.10.30.12";
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

  sops.secrets.staging-kenzie-password = {
    sopsFile = ../../secrets/staging/passwords.yaml;
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
      passwordFile = "${config.sops.secrets.staging-kenzie-password.path}";
      shell = pkgs.zsh;
    };

    users.root = {
      openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
      password = null;
      shell = pkgs.zsh;
    };
  };

  sops.secrets.common-gpg-keyring = {
    mode = "0040";
    group = "wheel";
    sopsFile = ../../secrets/common/common.yaml;
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;

    users.kenzie = import ../../home/home-linux-desktop.nix;
    users.root = import ../../home/home-linux-server.nix;
  };

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
