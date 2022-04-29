{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:4825764518/sops-nix/darwin";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs-stable.url = "github:serokell/deploy-rs";
    deploy-rs-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nix-darwin, home-manager, sops-nix
    , deploy-rs, deploy-rs-stable }:
    let
      inherit (nixpkgs) lib;
      platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllPlatforms = f: lib.genAttrs platforms (platform: f platform);
      patchedNixpkgs = forAllPlatforms (platform:
        let originalNixpkgs = (import nixpkgs { system = platform; });
        in originalNixpkgs.applyPatches {
          name = "patched-nixpkgs";
          src = nixpkgs;
          patches = [
            (originalNixpkgs.fetchpatch {
              url =
                "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/170748.patch";
              sha256 = "sha256-Vpw0UIlqiZut0Uyf2BoC7svJuTpW4KNHHdnqdYkY7hU=";
            })
          ];
        });

      nixpkgsFor = forAllPlatforms (platform:
        import patchedNixpkgs.${platform} {
          system = platform;
          config.allowUnfree = true;
          config.joypixels.acceptLicense = true;
        });

      pkgsNonfree-darwin-x64 = import nixpkgs {
        system = "x86_64-darwin";
        config.allowUnfree = true;
      };
    in {
      devShell.x86_64-linux =
        import ./shell.nix { pkgs = nixpkgsFor."x86_64-linux"; };
      devShell.aarch64-darwin =
        import ./shell.nix { pkgs = nixpkgsFor."aarch64-darwin"; };
      nixosConfigurations = {
        ainsel = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/ainsel/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        firelink = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/firelink/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        leyndell = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/leyndell/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        morne = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/morne/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
        };
        stormveil = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/stormveil/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
          ];
          pkgs = nixpkgsFor."x86_64-linux";
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
          pkgs = nixpkgsFor."aarch64-darwin";
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
