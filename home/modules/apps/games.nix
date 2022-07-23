{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.games;
  cataclysmUnstable = pkgs.cataclysm-dda-git.override {
    version = "2022-07-17";
    rev = "d06b4a2fb38e831b877a4e1da8107b2989ee4e10";
    sha256 = "sha256-G3AIlCqjkW6mCkvTKwPjLjoNjMXnOT4P4DMDacuHZmQ=";
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
