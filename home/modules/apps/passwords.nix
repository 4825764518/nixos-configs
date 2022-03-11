{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.passwords;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  options.profiles.home.applications.passwords = {
    enable = mkEnableOption "passwords";
  };

  config = mkIf (homeCfg.enable && cfg.enable) {
    home.packages = with pkgs; [ keepassxc ] ++ optionals isLinux [ bitwarden ];
  };
}
