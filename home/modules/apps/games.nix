{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.games;
  cataclysmUnstable = pkgs.cataclysm-dda-git.override {
    version = "2022-06-03";
    rev = "b70bca16173750e5eb3127d6eb93664221df4fb5";
    sha256 = "sha256-Ru6+Fn7uiqQJSqwQiSW7IQpO4GS3eCLOzUuUOzjbnS0=";
  };
  lutrisEnv = pkgs.lutris.override {
    extraPkgs =
      (pkgs: [ pkgs.opusfile pkgs.SDL2 pkgs.SDL2_net pkgs.SDL2_mixer ]);
  };
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  options.profiles.home.applications.games = {
    enable = mkEnableOption "games";
  };

  config = mkIf (homeCfg.enable && cfg.enable) {
    home.packages = with pkgs;
      [ cataclysmUnstable ] ++ optionals isLinux [
        # Emulators
        citra
        dolphin-emu-beta
        dosbox-staging
        lutrisEnv
        pcsx2
        polymc
        retroarchFull
        rpcs3
        yuzu-ea
      ];
  };
}
