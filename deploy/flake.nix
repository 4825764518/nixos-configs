{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:4825764518/sops-nix/darwin";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix, deploy-rs }: {
    apps."x86_64-linux".deploy-rs = deploy-rs.defaultApp."x86_64-linux";
    nixosConfigurations = {
      ainsel = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ../hosts/ainsel/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
      firelink = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ../hosts/firelink/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
      leyndell = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ../hosts/leyndell/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
      morne = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ../hosts/morne/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
    };
    deploy.nodes = {
      ainsel = {
        autoRollback = true;
        hostname = "ainsel";
        profiles.system = {
          sshUser = "dragonkin";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
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
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.firelink;
        };
      };
      leyndell = {
        autoRollback = true;
        hostname = "leyndell";
        profiles.system = {
          sshUser = "esgar";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.leyndell;
        };
      };
      morne = {
        autoRollback = true;
        hostname = "morne";
        profiles.system = {
          sshUser = "misbegotten";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.morne;
        };
      };
    };

    checks =
      builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy)
      deploy-rs.lib;
  };
}
