{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    firefox
    flameshot
    jellyfin-mpv-shim
    mpv
    obs-studio
    spotify
  ];
}
