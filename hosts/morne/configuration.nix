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

    wireguard.interfaces = {
      wg-internal = {
        ips = [ "192.168.171.1/24" ];
        listenPort = 51820;
        privateKeyFile = "${config.sops.secrets.morne-wireguard-privkey.path}";
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i %i -j ACCEPT; ${pkgs.iptables}/bin/iptables -A FORWARD -o %i -j ACCEPT; ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o enp1s0 -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i %i -j ACCEPT; ${pkgs.iptables}/bin/iptables -D FORWARD -o %i -j ACCEPT; ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enp1s0 -j MASQUERADE
        '';
        peers = [
          {
            # ovh
            publicKey = "Mo1wqAe5SNixIikRSlVY9DpT5Nz19mZenWym3voa0TM=";
            allowedIPs = [ "192.168.170.0/24" ];
            endpoint = "192.99.14.203:51820";
            persistentKeepalive = 25;
          }

          {
            # kiln
            publicKey = "1RS2Fub/Tl7jEFG8jlVici/B3Se+uwCa0fSpnerPSQw=";
            allowedIPs = [ "192.168.171.10/32" ];
            persistentKeepalive = 25;
          }

          {
            # firelink
            publicKey = "E8EtZnPIrYpEfq3G07pO2kHMR/ZR8hDw3QEa1Ab7vlI=";
            allowedIPs = [ "192.168.171.11/32" ];
            persistentKeepalive = 25;
          }

          {
            # stormveil
            publicKey = "yVSQqYaAFhUWVWdgRM1mRG79htZ91jL37gciPSuJ4S0=";
            allowedIPs = [ "192.168.171.20/32" ];
            persistentKeepalive = 25;
          }

          {
            # interloper 
            publicKey = "E3NUKOODIk6gSm85LtfzLJUwwXcKOeeli8dihRDgfQM=";
            allowedIPs = [ "10.67.238.34/32" ];
            persistentKeepalive = 25;
          }

          {
            # iphone
            publicKey = "Pa7NHFgi2r5JKD8LlhMk+3mctmbMcwXggf3pvIrebxQ=";
            allowedIPs = [ "10.64.57.118/32" ];
            persistentKeepalive = 25;
          }
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
  networking.firewall.allowedUDPPortRanges = [{
    from = 0;
    to = 65535;
  }];
  networking.firewall.allowedTCPPortRanges = [{
    from = 0;
    to = 65535;
  }];
}
