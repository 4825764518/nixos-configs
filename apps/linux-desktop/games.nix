{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ polymc ];

  programs.steam.enable = true;
}
