{ lib, config, pkgs, ... }:

let
  makeMullvadConfig = { publicKey, endpoint }: {
    address = [ "10.64.180.86/32" "fc00:bbbb:bbbb:bb01::1:b455/128" ];
    privateKeyFile =
      "${config.sops.secrets.stormveil-wireguard-mullvad-privkey.path}";
    peers = [{
      allowedIPs = [ "0.0.0.0/0" "::0/0" ];
      inherit publicKey endpoint;
    }];
  };
in {
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
      mullvad-ca15 = makeMullvadConfig {
        publicKey = "dn27fhdet9sxRl3biHeCBvA5edZMC03bh0zZIj3DJzI=";
        endpoint = "89.36.78.226:51820";
      };
      mullvad-jp3 = makeMullvadConfig {
        publicKey = "oWo/Ljb6SYqJYHHhRd8nKDjFJx9MqfouEYSJvba4XH4=";
        endpoint = "45.8.223.225:51820";
      };
      mullvad-md1 = makeMullvadConfig {
        publicKey = "BQobp2UXHJguYGz06WWJGJV6QytNIZlgMwr6Joufhx8=";
        endpoint = "178.175.131.98:51820";
      };
      mullvad-us241 = makeMullvadConfig {
        publicKey = "AgaO2dCgD3SNEW8II143+pcMREFsnkoieay25nFLxDs=";
        endpoint = "23.226.135.50:51820";
      };
      mullvad-us249 = makeMullvadConfig {
        publicKey = "TvqnL6VkJbz0KrjtHnUYWvA7zRt9ysI64LjTOx2vmm4=";
        endpoint = "198.54.135.130:51820";
      };
    };
    # use mullvad-us249 by default
    systemd.services.wg-quick-mullvad-ca15.wantedBy = lib.mkForce [ ];
    systemd.services.wg-quick-mullvad-jp3.wantedBy = lib.mkForce [ ];
    systemd.services.wg-quick-mullvad-md1.wantedBy = lib.mkForce [ ];
    systemd.services.wg-quick-mullvad-us241.wantedBy = lib.mkForce [ ];
  };
}
