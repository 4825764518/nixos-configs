{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.shell;
in {
  options.profiles.home.shell = {
    enable = mkEnableOption "shell";
    backend = mkOption {
      default = "zsh";
      type = types.str;
    };
  };

  config = mkIf (homeCfg.enable && cfg.enable) {
    programs.zsh = mkIf (cfg.backend == "zsh") {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;

      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        save = 50000;
      };

      oh-my-zsh = {
        enable = true;
        theme = "strug";
      };
    };
  };
}
