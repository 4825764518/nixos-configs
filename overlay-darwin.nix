self: super: {
  kitty = super.kitty.overrideAttrs (o: rec {
    patches = o.patches ++ super.lib.optionals super.stdenv.isDarwin
      [ ./pkgs/kitty/darwin.patch ];
  });
}
