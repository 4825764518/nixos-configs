{ config, pkgs, ... }:

{
  imports = [
    ../darwin-common.nix
    ../../apps/common.nix
    ../../apps/homebrew.nix
    ../../apps/nix.nix
  ];

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  users.users.kenzie = { home = "/Users/kenzie"; };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
