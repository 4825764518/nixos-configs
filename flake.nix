{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, sops-nix }:
    let pkgsNonfree = import nixpkgs { config.allowUnfree = true; };
    in {
      nixosConfigurations = {
        firelink = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [ ./hosts/firelink/configuration.nix sops-nix.nixosModules.sops ];
        };
        stormveil = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/stormveil/configuration.nix ];
          pkgs = pkgsNonfree;
        };
      };
      darwinConfigurations = {
        interloper = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ ./hosts/interloper/darwin-configuration.nix ];
        };
      };
    };
}
