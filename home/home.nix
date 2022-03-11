{ pkgs, lib, config, ... }:

with lib;

let cfg = config.profiles.home;
in {
  options.profiles.home = { enable = mkEnableOption "home"; };

  config = mkIf cfg.enable { programs.home-manager.enable = true; };
}
