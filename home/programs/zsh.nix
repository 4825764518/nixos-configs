{ config, lib, pkgs, ... }:

{
  config.programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      save = 50000;
    };

    oh-my-zsh = {
      enable = true;
      theme = "strug";
    };
  };
}
