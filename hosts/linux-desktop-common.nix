{ config, pkgs, ... }:

{
  imports = [
    ./linux-common.nix
    ../apps/gdm.nix
    ../apps/linux-desktop/development.nix
    ../apps/linux-desktop/games.nix
    ../apps/linux-desktop/media.nix
    ../apps/linux-desktop/passwords.nix
    ../apps/linux-desktop/social.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}
