{ lib, mkXfceDerivation, cairo, gtk3, glib, libwnck, libxfce4ui, libxfce4util
, xfce4-panel, xfconf }:

mkXfceDerivation {
  category = "panel-plugins";
  pname = "xfce4-docklike-plugin";
  version = "0.4.0";
  rev-prefix = "xfce4-docklike-plugin-";
  odd-unstable = false;
  sha256 = "sha256-rt1YA0cpgiM6MDojPySHDLAqNYxTBPlsffywS3goCRo=";

  buildInputs =
    [ cairo gtk3 glib libwnck libxfce4ui libxfce4util xfce4-panel xfconf ];

  NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";

  meta = with lib; {
    description = "A modern, docklike, minimalist taskbar for XFCE";
    maintainers = with maintainers; [ ] ++ teams.xfce.members;
  };
}
