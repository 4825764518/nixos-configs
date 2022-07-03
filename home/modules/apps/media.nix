{ config, lib, pkgs, ... }:

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
        jellyfin-media-player
        mpv
        mumble
        plex-media-player
        spotify
        thunderbird
        ungoogled-chromium
      ];

    programs.obs-studio = mkIf isLinux {
      enable = true;
      plugins = with pkgs.obs-studio-plugins;
        [
          (obs-nvfbc.overrideAttrs (oldAttrs: {
            version = "0.0.6";

            src = pkgs.fetchFromGitLab {
              owner = "fzwoch";
              repo = "obs-nvfbc";
              rev = "v0.0.6";
              sha256 = "sha256-WoqtppgIcjE0n9atsvAZrXvBVi2rWCIIFDXTgblQK9I=";
            };
          }))
        ];
    };
  };
}
