{ config, lib, pkgs, ... }:

let inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in (lib.mkIf isLinux {
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      # TODO: change this to whitesur when packaged in the future
      name = "Adwaita-Dark";
      package = pkgs.adwaita-qt;
    };
  };
})
