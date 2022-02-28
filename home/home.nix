{ pkgs, lib, config, ... }:

{
  imports = [ ./programs/gtk.nix ./programs/zsh.nix ];

  config.programs.home-manager.enable = true;
}
