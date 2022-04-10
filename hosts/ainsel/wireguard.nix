{ lib, config, pkgs, ... }:

{
  config = {
    sops.secrets.ainsel-wireguard-privkey = {
      sopsFile = ../../secrets/ainsel/wireguard.yaml;
    };
    networking.wireguard.interfaces = {
      wg-internal = {
        ips = [ "192.168.172.20/24" ];
        listenPort = 51820;
        privateKeyFile = "${config.sops.secrets.ainsel-wireguard-privkey.path}";
        peers = [
          {
            # ovh
            publicKey = "Mo1wqAe5SNixIikRSlVY9DpT5Nz19mZenWym3voa0TM=";
            allowedIPs = [ "192.168.170.0/24" ];
            endpoint = "192.99.14.203:51820";
            persistentKeepalive = 25;
          }
          {
            # morne
            publicKey = "+y5ZjN6GToEbF3fwRnwJJH+tDZsgEvsJXoKyno0SfVg=";
            allowedIPs =
              [ "192.168.171.0/24" "10.67.238.34/32" "10.64.57.118/32" ];
            endpoint = "51.222.128.114:51820";
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
            # firelink
            publicKey = "E8EtZnPIrYpEfq3G07pO2kHMR/ZR8hDw3QEa1Ab7vlI=";
            allowedIPs = [ "192.168.171.11/32" ];
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
