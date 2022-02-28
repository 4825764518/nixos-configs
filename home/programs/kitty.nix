{ config, lib, pkgs, ... }:

{
  config.programs.kitty = {
    enable = true;
    theme = "Obsidian";
  };
}
