{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.terminal;
in {
  options.profiles.home.terminal = {
    enable = mkEnableOption "terminal";
    backend = mkOption {
      default = "kitty";
      type = types.str;
    };
  };

  config = {
    programs.kitty = mkIf (cfg.backend == "kitty") {
      enable = true;
      font = {
        name = "Fira Mono";
        size = 10;
        package = pkgs.fira-mono;
      };
      theme = "Obsidian";
    };
  };
}
