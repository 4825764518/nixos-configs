{ config, lib, pkgs, ... }:

let inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in (lib.mkIf isLinux {
  gtk = {
    enable = true;
    font = {
      name = "Fira Mono";
      size = 10;
      package = pkgs.fira-mono;
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    gtk2.extraConfig = ''
      gtk-icon-name="Arc"
    '';
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
      "gtk-decoration-layout" = "menu:minimize,maximize,close";
      "gtk-icon-theme-name" = "Arc";
      "gtk-theme-name" = "Arc-Dark";
      "gtk-toolbar-style" = "GTK_TOOLBAR_BOTH_HORIZ";
    };
  };
})
