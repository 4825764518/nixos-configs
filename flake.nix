{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs/4d60081494259c0785f7e228518fee74e0792c1b";
    nixos-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    sops-nix.url = "github:4825764518/sops-nix/darwin";
    # sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixos";
    deploy-rs-stable.url = "github:serokell/deploy-rs";
    deploy-rs-stable.inputs.nixpkgs.follows = "nixos-stable";
  };

  outputs = { self, nixpkgs, nixos, nixos-small, nixos-stable, nix-darwin
    , home-manager, sops-nix, deploy-rs, deploy-rs-stable }:
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
        ainsel = nixos-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/ainsel/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        firelink = nixos-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/firelink/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        leyndell = nixos-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/leyndell/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        morne = nixos-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/morne/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        stormveil = nixos.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/stormveil/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
          pkgs = pkgsNonfree-linux-x64;
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
      deploy.nodes = {
        ainsel = {
          autoRollback = true;
          hostname = "ainsel";
          profiles.system = {
            sshUser = "dragonkin";
            user = "root";
            path = deploy-rs-stable.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.ainsel;
          };
        };
        firelink = {
          autoRollback = true;
          fastConnection = true;
          hostname = "firelink";
          profiles.system = {
            sshUser = "shrinekeeper";
            user = "root";
            path = deploy-rs-stable.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.firelink;
          };
        };
        leyndell = {
          autoRollback = true;
          hostname = "leyndell";
          profiles.system = {
            sshUser = "esgar";
            user = "root";
            path = deploy-rs-stable.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.leyndell;
          };
        };
        morne = {
          autoRollback = true;
          hostname = "morne";
          profiles.system = {
            sshUser = "misbegotten";
            user = "root";
            path = deploy-rs-stable.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.morne;
          };
        };
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy)
        deploy-rs-stable.lib;
    };
}
