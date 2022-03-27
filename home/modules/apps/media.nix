{ config, lib, pkgs, intelPkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.media;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  options.profiles.home.applications.media = {
    enable = mkEnableOption "media";
  };

  config = mkIf (homeCfg.enable && cfg.enable) {
    home.packages = with pkgs;
      optionals isLinux [
        firefox
        flameshot
        gimp
        inkscape-with-extensions
        jellyfin-mpv-shim
        mpv
        obs-studio
        spotify
      ] ++ optionals isDarwin [ intelPkgs.inkscape-with-extensions ];
  };
}
