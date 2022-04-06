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
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    theme = { name = "Adwaita-dark"; };
    gtk2.extraConfig = ''
      gtk-icon-theme-name="Adwaita"
      gtk-theme-name="Adwaita-dark"
      gtk-font-name="Fira Mono 10"
    '';
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
      "gtk-font-name" = "Fira Mono 10";
      "gtk-icon-theme-name" = "Adwaita";
      "gtk-theme-name" = "Adwaita-dark";
      "gtk-toolbar-style" = "GTK_TOOLBAR_BOTH_HORIZ";
    };
    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
      "gtk-decoration-layout" = "menu:minimize,maximize,close";
      "gtk-font-name" = "Fira Mono 10";
      "gtk-hint-font-metrics" = 1;
      "gtk-icon-theme-name" = "Adwaita";
      "gtk-theme-name" = "Adwaita-dark";
      "gtk-toolbar-style" = "GTK_TOOLBAR_BOTH_HORIZ";
    };
  };
})
