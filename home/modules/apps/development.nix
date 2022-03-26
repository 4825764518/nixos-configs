{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.applications.development;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  options.profiles.home.applications.development = {
    enable = mkEnableOption "development";
  };

  config = mkIf (homeCfg.enable && cfg.enable) {
    home.packages = with pkgs;
      [ # Nix tools
        nix-prefetch
        nix-prefetch-git

        # Misc tools
        sqlitebrowser
      ] ++ optionals isLinux [
        # Editors
        jetbrains.clion
        jetbrains.goland
        jetbrains.idea-ultimate
        jetbrains.pycharm-professional
        jetbrains.rider
        vscode

        # Tools
        cutter
        ghidra
        libreoffice-fresh
        postman
        sqlitebrowser
      ];
  };
}
