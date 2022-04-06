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
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };
    theme = {
      name = "WhiteSur-dark-solid-pink";
      package = pkgs.whitesur-gtk-theme.overrideAttrs (oldAttrs: {
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/themes
          ./install.sh --dest $out/share/themes -i simple --alt all --theme all 
          runHook postInstall
        '';
      });
    };
    gtk2.extraConfig = ''
      gtk-icon-theme-name="WhiteSur-dark"
      gtk-theme-name="WhiteSur-dark-solid-pink"
      gtk-font-name="Fira Mono 10"
    '';
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
      "gtk-font-name" = "Fira Mono 10";
      "gtk-icon-theme-name" = "WhiteSur-dark";
      "gtk-theme-name" = "WhiteSur-dark-solid-pink";
      "gtk-toolbar-style" = "GTK_TOOLBAR_BOTH_HORIZ";
    };
    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
      "gtk-decoration-layout" = "menu:minimize,maximize,close";
      "gtk-font-name" = "Fira Mono 10";
      "gtk-hint-font-metrics" = 1;
      "gtk-icon-theme-name" = "WhiteSur-dark";
      "gtk-theme-name" = "WhiteSur-dark-solid-pink";
      "gtk-toolbar-style" = "GTK_TOOLBAR_BOTH_HORIZ";
    };
  };
})
