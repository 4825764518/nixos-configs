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
        ips = [ "192.168.170.20/24" ];
        listenPort = 51820;
        privateKeyFile =
          "${config.sops.secrets.stormveil-wireguard-privkey.path}";
        peers = [{
          publicKey = "Mo1wqAe5SNixIikRSlVY9DpT5Nz19mZenWym3voa0TM=";
          allowedIPs = [ "192.168.170.0/24" ];
          endpoint = "192.99.14.203:51820";
          persistentKeepalive = 25;
        }];
      };
    };
    networking.wg-quick.interfaces = {
      mullvad-us241 = {
        address = [ "10.64.180.86/32" "fc00:bbbb:bbbb:bb01::1:b455/128" ];
        privateKeyFile =
          "${config.sops.secrets.stormveil-wireguard-mullvad-privkey.path}";
        peers = [{
          publicKey = "AgaO2dCgD3SNEW8II143+pcMREFsnkoieay25nFLxDs=";
          allowedIPs = [
            "0.0.0.0/4"
            "16.0.0.0/6"
            "20.0.0.0/7"
            "22.0.0.0/8"
            "23.0.0.0/9"
            "23.128.0.0/10"
            "23.192.0.0/11"
            "23.224.0.0/15"
            "23.226.0.0/17"
            "23.226.128.0/22"
            "23.226.132.0/23"
            "23.226.134.0/24"
            "23.226.135.0/27"
            "23.226.135.32/28"
            "23.226.135.48/31"
            "23.226.135.51/32"
            "23.226.135.52/30"
            "23.226.135.56/29"
            "23.226.135.64/26"
            "23.226.135.128/25"
            "23.226.136.0/21"
            "23.226.144.0/20"
            "23.226.160.0/19"
            "23.226.192.0/18"
            "23.227.0.0/16"
            "23.228.0.0/14"
            "23.232.0.0/13"
            "23.240.0.0/12"
            "24.0.0.0/5"
            "32.0.0.0/3"
            "64.0.0.0/2"
            "128.0.0.0/2"
            "192.0.0.0/9"
            "192.128.0.0/11"
            "192.160.0.0/13"
            "192.169.0.0/16"
            "192.170.0.0/15"
            "192.172.0.0/14"
            "192.176.0.0/12"
            "192.192.0.0/10"
            "193.0.0.0/8"
            "194.0.0.0/7"
            "196.0.0.0/6"
            "200.0.0.0/5"
            "208.0.0.0/4"
            "224.0.0.0/3"
            "::0/0"
          ];
          endpoint = "23.226.135.50:51820";
        }];
      };
    };
  };
}
