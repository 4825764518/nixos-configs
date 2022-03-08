{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "4825764518";
    userEmail = "100122841+4825764518@users.noreply.github.com";

    signing = {
      key = "A9FDDC6F9E5CB8AC";
      signByDefault = true;
    };

    extraConfig = {
      core = { editor = "code --wait"; };
      diff = { tool = "vscode"; };
      difftool.vscode = { cmd = "code --wait --diff $LOCAL $REMOTE"; };
      merge = { tool = "vscode"; };
      mergetool.vscode = { cmd = "code --wait $MERGED"; };
    };
  };
}
