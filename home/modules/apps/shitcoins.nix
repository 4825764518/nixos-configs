{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.shitcoins;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  options.profiles.home.applications.shitcoins = {
    enable = mkEnableOption "shitcoins";
  };

  config = mkIf (homeCfg.enable && cfg.enable) {
    home.packages = with pkgs; [ monero-gui ] ++ optionals isLinux [ xmrig-mo ];
  };
}
