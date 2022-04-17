{ config, pkgs, ... }:

{
  imports = [
    ../darwin-common.nix
    ../../apps/homebrew.nix
    ../../apps/nix.nix
  ];

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  users.users.kenzie = { home = "/Users/kenzie"; };

  sops.secrets.common-gpg-keyring = {
    mode = "0040";
    group = "staff";
    sopsFile = ../../secrets/common/common.yaml;
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;

    users.kenzie = import ../../home/home-darwin.nix;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
