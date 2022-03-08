{ pkgs, lib, config, ... }:

{
  imports = [
    ./programs/darwin.nix
    ./programs/gpg.nix
    ./programs/gtk.nix
    ./programs/kitty.nix
    ./programs/zsh.nix
  ];

  config.fonts.fontconfig.enable = true;
  config.programs.home-manager.enable = true;
}
