{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ xfce.xfce4-whiskermenu-plugin ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  services.xserver.desktopManager.xfce.enable = true;
}
