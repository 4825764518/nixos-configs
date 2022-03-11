{ pkgs, lib, config, ... }:

{
  imports = [
    ./home.nix
    ./modules/darwin.nix
    ./modules/shell.nix
    ./modules/terminal.nix

    ./modules/apps/shitcoins.nix

    # TODO
    ./modules/git.nix
    ./modules/gpg.nix
  ];

  config = {
    fonts.fontconfig.enable = true;

    profiles.home.enable = true;
    profiles.home.shell.enable = true;
    profiles.home.terminal.enable = true;

    profiles.home.applications.shitcoins.enable = true;
  };
}
