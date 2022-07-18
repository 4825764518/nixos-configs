{ lib, config, pkgs, ... }:

let wireguardPeers = import ../wireguard-peers.nix { inherit lib; };
in {
  config = {
    sops.secrets.ainsel-wireguard-privkey = {
      sopsFile = ../../secrets/ainsel/wireguard.yaml;
    };
    sops.secrets.ainsel-wireguard-mullvad-privkey = {
      sopsFile = ../../secrets/ainsel/wireguard.yaml;
    };
    networking.wireguard.interfaces = {
      wg-internal = {
        ips = [
          "192.168.172.20/24"
          "192.168.173.20/24"
          "fdc3:62d8:4c3a:0020::/64"
        ];
        listenPort = 51820;
        privateKeyFile = "${config.sops.secrets.ainsel-wireguard-privkey.path}";
        peers = [
          wireguardPeers.clientPeers.firelinkPeer
          wireguardPeers.serverPeers.leyndellPeer
          (wireguardPeers.serverPeers.mornePeer false)
          wireguardPeers.serverPeers.ovhPeer
        ];
      };
      wg-mullvad-fi1 = {
        privateKeyFile =
          "${config.sops.secrets.ainsel-wireguard-mullvad-privkey.path}";
        ips = [ "10.66.75.124/32" ];
        peers = [{
          publicKey = "rGL76wTvmRKI2f8VHdGEZnTQbwRG4+RTO1sokGouVGU=";
          allowedIPs = [ "10.64.0.1/32" ];
          endpoint = "185.204.1.203:51820";
        }];
      };
    };
  };
}
