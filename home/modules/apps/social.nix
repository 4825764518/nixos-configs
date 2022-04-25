{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.social;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  options.profiles.home.applications.social = {
    enable = mkEnableOption "social";
  };

  config = mkIf (homeCfg.enable && cfg.enable) {
    home.packages = with pkgs; optionals isLinux [ discord element-desktop signal-desktop tdesktop ];
  };
}
