{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ file git htop screen wget ];
}
