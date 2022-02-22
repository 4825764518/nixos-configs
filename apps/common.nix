{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ file git htop sops wget ];
}
