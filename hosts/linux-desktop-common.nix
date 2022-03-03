{ config, pkgs, ... }:

{
  imports = [
    ./linux-common.nix
    ../apps/lightdm.nix
    ../apps/linux-desktop/development.nix
    ../apps/linux-desktop/games.nix
    ../apps/linux-desktop/media.nix
    ../apps/linux-desktop/mining.nix
    ../apps/linux-desktop/misc.nix
    ../apps/linux-desktop/passwords.nix
    ../apps/linux-desktop/social.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "v4l2loopback" "zenpower" ];

  environment.systemPackages = with pkgs; [ lm_sensors ];

  fonts.fonts = with pkgs; [ fira fira-mono fira-code fira-code-symbols ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
}
