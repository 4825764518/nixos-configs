{ pkgs, lib, config, ... }:

with lib;

{
  imports = [ ./home.nix ./modules/shell.nix ];

  config = {
    profiles.home.enable = true;
    profiles.home.shell.enable = true;

    targets.genericLinux.enable = true;
  };
}
