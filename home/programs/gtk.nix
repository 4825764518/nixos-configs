{ config, lib, pkgs, ... }:

let inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in (lib.mkIf isLinux {
  gtk = {
    enable = true;
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
      gtk-font-name="Noto Sans,  10"
    '';
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
      "gtk-font-name" = "Noto Sans,  10";
      "gtk-icon-theme-name" = "Arc";
      "gtk-theme-name" = "Arc-Dark";
    };
  };
})
