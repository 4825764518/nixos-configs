{ config, pkgs, ... }:

{
  imports = [
    ./linux-common.nix
    ../apps/gdm.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}
