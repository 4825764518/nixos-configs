{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    citra
    dolphin-emu-beta
    lutris
    pcsx2
    polymc
    rpcs3
    yuzu-ea
  ];

  programs.steam.enable = true;
}
