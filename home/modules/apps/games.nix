{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.games;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  options.profiles.home.applications.games = {
    enable = mkEnableOption "games";
  };

  config = mkIf (homeCfg.enable && cfg.enable) {
    home.packages = with pkgs; optionals isLinux [
      # Emulators
      citra
      dolphin-emu-beta
      lutris
      pcsx2
      polymc
      retroarchFull
      rpcs3
      yuzu-ea
    ];
  };
}
