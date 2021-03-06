{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:4825764518/sops-nix/darwin";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix }:
    let
      inherit (nixpkgs) lib;
      platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllPlatforms = f: lib.genAttrs platforms (platform: f platform);
      patchedNixpkgs = forAllPlatforms (platform:
        let originalNixpkgs = (import nixpkgs { system = platform; });
        in
        originalNixpkgs.applyPatches {
          name = "patched-nixpkgs";
          src = nixpkgs;
          patches = [
            # (originalNixpkgs.fetchpatch {
            #   url =
            #     "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/170748.patch";
            #   sha256 = "sha256-Vpw0UIlqiZut0Uyf2BoC7svJuTpW4KNHHdnqdYkY7hU=";
            # })
            # (originalNixpkgs.fetchpatch {
            #   url =
            #     "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/170798.patch";
            #   sha256 = "sha256-TYgv6YgEPjHZNRvPXpMoUy4BvNy+9XLqyQZ2CJTLB6k=";
            # })
            (originalNixpkgs.fetchpatch {
              url =
                "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/167230.patch";
              sha256 = "sha256-cXcojtJFdJdS9jJpP5WFhIou/LvWemJSofgRjjae/R4=";
            })
          ];
        });

      nixpkgsFor =
        let
          restic-overlay = (final: prev: {
            restic =
              final.callPackage (import pkgs/restic-unstable/default.nix) { };
          });
        in
        forAllPlatforms (platform:
          import patchedNixpkgs.${platform} {
            system = platform;
            config.allowUnfree = true;
            config.packageOverrides = pkgs: {
              arc = import
                (builtins.fetchTarball {
                  url =
                    "https://github.com/arcnmx/nixexprs/archive/bf7e09b35e1f36eb3d5b687eee85ce38b539eb92.tar.gz";
                  sha256 =
                    "sha256:19v3ad3dvmqi10ww0q1ddw8hm658sfywaxbx9spaw4jjbz6c35fs";
                })
                { inherit pkgs; };
              steam = pkgs.steam.override {
                extraPkgs = pkgs: with pkgs; [ xorg.libXaw ];
              };
            };

            overlays = [ restic-overlay ];
          });

      pkgsNonfree-darwin-x64 = import nixpkgs {
        system = "x86_64-darwin";
        config.allowUnfree = true;
      };
    in
    {
      devShell.x86_64-linux =
        import ./shell.nix { pkgs = nixpkgsFor."x86_64-linux"; };
      devShell.aarch64-darwin =
        import ./shell.nix { pkgs = nixpkgsFor."aarch64-darwin"; };
      nixosConfigurations = {
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
        nihilanth = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/nihilanth/darwin-configuration.nix
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
    };
}
