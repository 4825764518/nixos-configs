{ lib, config, pkgs, ... }:

let wireguardPeers = import ../wireguard-peers.nix { inherit lib; };
in {
  config = {
    sops.secrets.ainsel-wireguard-privkey = {
      sopsFile = ../../secrets/ainsel/wireguard.yaml;
    };
    sops.secrets.ainsel-wireguard-media-privkey = {
      sopsFile = ../../secrets/ainsel/wireguard.yaml;
    };
    networking.wireguard.interfaces = {
      wg-internal = {
        ips = [ "192.168.172.20/24" "fdc3:62d8:4c3a:0020::/64" ];
        listenPort = 51820;
        privateKeyFile = "${config.sops.secrets.ainsel-wireguard-privkey.path}";
        peers = [
          wireguardPeers.clientPeers.firelinkPeer
          wireguardPeers.serverPeers.leyndellPeer
          (wireguardPeers.serverPeers.mornePeer false)
          wireguardPeers.serverPeers.ovhPeer
        ];
      };
      wg-media = {
        ips = [ "192.168.173.20/24" ];
        listenPort = 51821;
        privateKeyFile =
          "${config.sops.secrets.ainsel-wireguard-media-privkey.path}";
        peers = [ (wireguardPeers.mediaPeers.mornePeer false) ];
      };
    };
  };
}
