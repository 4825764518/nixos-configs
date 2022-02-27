{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ bitwarden keepassxc ];
}
