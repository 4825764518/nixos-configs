{ config, lib, pkgs, ... }:

{
  config.programs.kitty = {
    enable = true;
    font = {
      name = "Fira Mono";
      size = 10;
      package = pkgs.fira-mono;
    };
    theme = "Obsidian";
  };
}
