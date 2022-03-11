{ pkgs, lib, config, ... }:

with lib;

{
  imports = [
    ./home.nix
    ./modules/shell.nix
    ./modules/terminal.nix

    ./modules/apps/development.nix
    ./modules/apps/games.nix
    ./modules/apps/media.nix
    ./modules/apps/passwords.nix
    ./modules/apps/shitcoins.nix
    ./modules/apps/social.nix

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

    profiles.home.applications.development.enable = true;
    profiles.home.applications.games.enable = true;
    profiles.home.applications.media.enable = true;
    profiles.home.applications.passwords.enable = true;
    profiles.home.applications.shitcoins.enable = true;
    profiles.home.applications.social.enable = true;

    targets.genericLinux.enable = true;
  };
}
