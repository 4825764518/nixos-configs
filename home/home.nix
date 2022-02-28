{ pkgs, lib, config, ... }:

{
  imports = [ ./programs/gtk.nix ];

  config.programs.home-manager.enable = true;
  config.programs.bash.enable = true;
}
