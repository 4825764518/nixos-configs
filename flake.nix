{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    sops-nix.url = "github:4825764518/sops-nix/darwin";
    # sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos, nix-darwin, home-manager, sops-nix }:
    let
      pkgsNonfree-linux-x64 = import nixos {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      pkgsNonfree-darwin-aarch64 = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        firelink = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [ ./hosts/firelink/configuration.nix sops-nix.nixosModules.sops ];
        };
        stormveil = nixos.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/stormveil/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.verbose = true;
              home-manager.users.kenzie = import ./home/home.nix;
            }
          ];
          pkgs = pkgsNonfree-linux-x64;
        };
      };
      darwinConfigurations = {
        interloper = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/interloper/darwin-configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.kenzie = import ./home/home.nix;
            }
          ];
          pkgs = pkgsNonfree-darwin-aarch64;
        };
      };
    };
}
