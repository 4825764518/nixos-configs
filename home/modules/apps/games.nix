{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.games;
  cataclysmUnstable = pkgs.cataclysm-dda-git.override {
    version = "2022-04-13";
    rev = "a1cea1e8526ed76e86b89e161829299e2b8d7c19";
    sha256 = "0dz6674sf0s3gh08pgka5x1nypazkg5yb1kpicrc112wmvs4cd0d";
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
