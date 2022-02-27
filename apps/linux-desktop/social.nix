{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ discord element-desktop ];
}
