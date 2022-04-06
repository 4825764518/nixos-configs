{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    sops-nix.url = "github:4825764518/sops-nix/darwin";
    # sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, nixos, nixos-small, nix-darwin, home-manager, sops-nix }:
    let
      darwinOverlay = import ./overlay-darwin.nix;
      pkgsNonfree-linux-x64 = import nixos {
        system = "x86_64-linux";
        config.allowUnfree = true;
        config.joypixels.acceptLicense = true;
      };
      pkgsNonfree-linux-x64-small = import nixos-small {
        system = "x86_64-linux";
        config.allowUnfree = true;
        config.joypixels.acceptLicense = true;
      };
      pkgsNonfree-darwin-x64 = import nixpkgs {
        system = "x86_64-darwin";
        config.allowUnfree = true;
      };
      pkgsNonfree-darwin-aarch64 = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        overlays = [ darwinOverlay ];
      };
    in {
      devShell.x86_64-linux =
        import ./shell.nix { pkgs = pkgsNonfree-linux-x64; };
      devShell.aarch64-darwin =
        import ./shell.nix { pkgs = pkgsNonfree-darwin-aarch64; };
      nixosConfigurations = {
        firelink = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/firelink/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        morne = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/morne/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        stormveil = nixos-small.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/stormveil/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
          pkgs = pkgsNonfree-linux-x64-small;
        };
      };
      darwinConfigurations = {
        interloper = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/interloper/darwin-configuration.nix
            sops-nix.darwinModules.sops
            { sops.age.sshKeyPaths = [ "/var/root/.sops-keys/id_ed25519" ]; }
            home-manager.darwinModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                intelPkgs = pkgsNonfree-darwin-x64;
              };
            }
          ];
          pkgs = pkgsNonfree-darwin-aarch64;
          inputs = {
            inherit self;
            intelPkgs = pkgsNonfree-darwin-x64;
          };
        };
      };
    };
}
