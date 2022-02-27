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

    interfaces.enp34s0 = {
      ipv4.addresses = [{
        address = "10.10.30.20";
        prefixLength = 24;
      }];
    };
    defaultGateway = "10.10.30.1";
    nameservers = [ "10.10.30.1" ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
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
  services.openssh.permitRootLogin = "yes";

  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
