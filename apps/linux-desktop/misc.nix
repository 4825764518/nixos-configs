{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ gwe libreoffice-fresh ];
}
