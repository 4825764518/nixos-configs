{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      sunshine = pkgs.callPackage ./default.nix {};
    in {
      packages.x86_64-linux.sunshine = sunshine;
      defaultPackage.x86_64-linux = sunshine;
    };
}
