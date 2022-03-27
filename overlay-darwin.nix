self: super: {
  inkscape = super.inkscape.overrideAttrs (o: rec {
    darwinBundle = super.makeDarwinBundle {
      name = "Inkscape";
      exec = "inkscape";
    };
    nativeBuildInputs = o.nativeBuildInputs
      ++ super.lib.optionals super.stdenv.isDarwin [ darwinBundle ];
  });
  kitty = super.kitty.overrideAttrs (o: rec {
    patches = o.patches ++ super.lib.optionals super.stdenv.isDarwin
      [ ./pkgs/kitty/darwin.patch ];
  });
}
