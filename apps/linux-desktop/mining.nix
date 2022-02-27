{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ monero-gui xmrig-mo ];
}
