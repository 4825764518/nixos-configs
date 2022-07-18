{ lib, config, pkgs, ... }:

let wireguardPeers = import ../wireguard-peers.nix { inherit lib; };
in {
  config = {
    sops.secrets.leyndell-wireguard-privkey = {
      sopsFile = ../../secrets/leyndell/wireguard.yaml;
    };
    sops.secrets.leyndell-wireguard-mullvad-privkey = {
      sopsFile = ../../secrets/leyndell/wireguard.yaml;
    };
    networking.wireguard.interfaces = {
      wg-internal = {
        ips = [ "192.168.172.10/24" "fdc3:62d8:4c3a:0010::/64" ];
        listenPort = 51820;
        privateKeyFile =
          "${config.sops.secrets.leyndell-wireguard-privkey.path}";
        peers = [
          wireguardPeers.serverPeers.ainselPeer
          (wireguardPeers.serverPeers.mornePeer false)
          wireguardPeers.serverPeers.ovhPeer
        ];
      };
      wg-mullvad-fi1 = {
        privateKeyFile =
          "${config.sops.secrets.leyndell-wireguard-mullvad-privkey.path}";
        ips = [ "10.65.222.173/32" ];
        peers = [{
          publicKey = "rGL76wTvmRKI2f8VHdGEZnTQbwRG4+RTO1sokGouVGU=";
          allowedIPs = [ "10.64.0.1/32" ];
          endpoint = "185.204.1.203:51820";
        }];
      };
    };
  };
}
