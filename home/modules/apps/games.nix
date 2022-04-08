{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.games;
  # lutrisEnv = pkgs.lutris.overrideAttrs
  #   (oldAttrs: rec { targetPkgs = pkgs: with pkgs; [ opusfile ] ++ (oldAttrs.targetPkgs { pkgs }); });
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
      optionals isLinux [
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
