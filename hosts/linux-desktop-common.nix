{ config, lib, pkgs, ... }:

{
  imports = [ ./linux-common.nix ../apps/lightdm.nix ];

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback.out ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  boot.kernelModules = [ "v4l2loopback" "zenpower" ];
  boot.blacklistedKernelModules = [ "snd_hda_codec_hdmi" ];

  environment.systemPackages = with pkgs; [
    gnomeExtensions.logo-menu
    gnomeExtensions.user-themes
    gnomeExtensions.vitals
    lm_sensors
    qgnomeplatform
    usbutils
    mangohud
  ];

  fonts.fontconfig = {
    cache32Bit = true;
    enable = true;
    defaultFonts = {
      sansSerif = [ "Fira Sans" ];
      serif = [ "Fira Sans" ];
      monospace = [ "Fira Mono" ];
      emoji = [ "Twitter Color Emoji" "Noto Color Emoji" ];
    };
  };

  fonts.fonts = with pkgs; [ fira fira-mono fira-code fira-code-symbols ];

  programs.dconf.enable = true;
  programs.steam.enable = true;

  services.flatpak.enable = true;
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    jack.enable = true;
    alsa.enable = true;
    pulse.enable = true;

    alsa.support32Bit = true;
  };

  services.xserver = {
    libinput.mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
    };
  };
}
