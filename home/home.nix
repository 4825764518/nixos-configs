{ pkgs, lib, config, ... }:

with lib;

let cfg = config.profiles.home;
in {
  imports = [ ./modules/shell.nix ./modules/terminal.nix ];

  options.profiles.home = { enable = mkEnableOption "home"; };

  config = mkIf cfg.enable {
    programs.home-manager.enable = true;
    home.stateVersion = "18.09";
  };
}
