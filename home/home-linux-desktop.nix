{ pkgs, lib, config, ... }:

with lib;

{
  imports = [
    ./home.nix
    ./modules/shell.nix
    ./modules/terminal.nix

    # TODO
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/gtk.nix
  ];

  config = {
    fonts.fontconfig.enable = true;

    profiles.home.enable = true;
    profiles.home.shell.enable = true;
    profiles.home.terminal.enable = true;
  };
}
