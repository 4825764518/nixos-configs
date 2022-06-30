{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (callPackage ../pkgs/xfce4-docklike-plugin {
      # 🤢
      inherit (xfce)
        mkXfceDerivation libxfce4ui libxfce4util xfce4-panel xfconf;
    })
    xfce.xfce4-whiskermenu-plugin
    qalculate-gtk
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  services.xserver.desktopManager.xfce.enable = true;
}
