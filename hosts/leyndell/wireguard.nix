{ lib, config, pkgs, ... }:

{
  config = {
    sops.secrets.leyndell-wireguard-privkey = {
      sopsFile = ../../secrets/leyndell/wireguard.yaml;
    };
    networking.wireguard.interfaces = {
      wg-internal = {
        ips = [ "192.168.172.10/24" ];
        listenPort = 51820;
        privateKeyFile =
          "${config.sops.secrets.leyndell-wireguard-privkey.path}";
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
            # ainsel
            publicKey = "eY/49qo0cPnTAw6Kl0AwlGE/jU+jrkdCNHXVtSNvfn0=";
            allowedIPs = [ "192.168.172.20/32" ];
            endpoint = "65.21.233.174:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
