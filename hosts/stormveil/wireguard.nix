{ lib, config, pkgs, ... }:

{
  config = {
    sops.secrets.stormveil-wireguard-privkey = {
      sopsFile = ../../secrets/stormveil/wireguard.yaml;
    };
    sops.secrets.stormveil-wireguard-mullvad-privkey = {
      sopsFile = ../../secrets/stormveil/wireguard.yaml;
    };
    networking.wireguard.interfaces = {
      wg-internal = {
        ips = [ "192.168.171.20/24" ];
        listenPort = 51820;
        privateKeyFile =
          "${config.sops.secrets.stormveil-wireguard-privkey.path}";
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
        ];
      };
    };
    networking.wg-quick.interfaces = {
      mullvad-us241 = {
        address = [ "10.64.180.86/32" "fc00:bbbb:bbbb:bb01::1:b455/128" ];
        privateKeyFile =
          "${config.sops.secrets.stormveil-wireguard-mullvad-privkey.path}";
        peers = [{
          publicKey = "AgaO2dCgD3SNEW8II143+pcMREFsnkoieay25nFLxDs=";
          allowedIPs = [ "0.0.0.0/0" "::0/0" ];
          endpoint = "23.226.135.50:51820";
        }];
      };
    };
  };
}
