{ pkgs, lib, config, ... }:

{
  imports = [
    ./home.nix
    ./modules/darwin.nix
    ./modules/shell.nix
    ./modules/terminal.nix

    ./modules/apps/development.nix
    ./modules/apps/media.nix

    # TODO
    ./modules/firefox.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/ssh.nix
  ];

  config = {
    fonts.fontconfig.enable = true;

    profiles.home.enable = true;
    profiles.home.shell.enable = true;
    profiles.home.terminal.enable = true;

    profiles.home.applications.development.enable = true;
    profiles.home.applications.media.enable = true;
  };
}
