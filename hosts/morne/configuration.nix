{ config, lib, pkgs, ... }:

{
  imports = [ ../linux-common.nix ./hardware-configuration.nix ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.hostName = "morne";
  time.timeZone = "America/New_York";

  sops.secrets.morne-wireguard-privkey = {
    sopsFile = ../../secrets/morne/wireguard.yaml;
  };
  networking = {
    defaultGateway = "192.99.14.254";
    defaultGateway6 = {
      address = "2607:5300:60:3fff:ff:ff:ff:ff";
      interface = "enp1s0";
    };

    useDHCP = false;

    interfaces.enp1s0 = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "51.222.128.114";
        prefixLength = 32;
      }];
      ipv4.routes = [{
        address = "192.99.14.254";
        prefixLength = 32;
        via = "0.0.0.0";
        options = { scope = "link"; };
      }];
      ipv6.addresses = [{
        address = "2607:5300:60:3fcb::2";
        prefixLength = 64;
      }];
    };

    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    wireguard.interfaces =
      let wireguardPeers = import ../wireguard-peers.nix { inherit lib; };
      in {
        wg-internal = {
          ips = [ "192.168.171.1/24" ];
          listenPort = 51820;
          privateKeyFile =
            "${config.sops.secrets.morne-wireguard-privkey.path}";
          peers = [
            wireguardPeers.clientPeers.firelinkPeer
            wireguardPeers.clientPeers.kilnPeer
            wireguardPeers.clientPeers.stormveilPeer
            wireguardPeers.clientPeers.interloperPeer
            wireguardPeers.clientPeers.iphonePeer
            wireguardPeers.clientPeers.iphoneProPeer

            wireguardPeers.serverPeers.ainselPeer
            wireguardPeers.serverPeers.leyndellPeer
            wireguardPeers.serverPeers.ovhPeer
          ];
        };
      };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users = {
    users.misbegotten = {
      isNormalUser = true;
      home = "/home/misbegotten";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keyFiles = [ ../authorized-keys-common ];
      shell = pkgs.zsh;
    };

    users.root = {
      password = null;
      shell = pkgs.zsh;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;

    users.misbegotten = import ../../home/home-linux-server.nix;
    users.root = import ../../home/home-linux-server.nix;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    challengeResponseAuthentication = false;
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 51820 ];
  networking.firewall.allowedUDPPorts = [ 22 51820 ];
}
