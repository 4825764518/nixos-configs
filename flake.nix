{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin }: {
    nixosConfigurations = {
      # TODO
    };
    darwinConfigurations = {
      interloper = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./hosts/interloper/darwin-configuration.nix ];
      };
    };
  };
}
