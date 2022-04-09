{ config, pkgs, ... }:

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
    };

    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    wireguard.interfaces =
      let commonPeers = import ../wireguard-peers-common.nix { };
      in {
        wg-internal = {
          ips = [ "192.168.171.1/24" ];
          listenPort = 51820;
          privateKeyFile =
            "${config.sops.secrets.morne-wireguard-privkey.path}";
          peers = [
            {
              # ovh
              publicKey = "Mo1wqAe5SNixIikRSlVY9DpT5Nz19mZenWym3voa0TM=";
              allowedIPs = [ "192.168.170.0/24" ];
              endpoint = "192.99.14.203:51820";
              persistentKeepalive = 25;
            }
            {
              # leyndell
              publicKey = "+YVWahC4Rd7CZyWyaxYO1iyvOoFV4yUK4OfXWSbF+Ac=";
              allowedIPs = [ "192.168.172.10/32" ];
              endpoint = "65.108.197.14:51820";
              persistentKeepalive = 25;
            }
            {
              # ainsel
              publicKey = "eY/49qo0cPnTAw6Kl0AwlGE/jU+jrkdCNHXVtSNvfn0=";
              allowedIPs = [ "192.168.172.20/32" ];
              endpoint = "65.21.233.174:51820";
              persistentKeepalive = 25;
            }
          ] ++ commonPeers;
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
