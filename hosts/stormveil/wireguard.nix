{ lib, config, pkgs, ... }:

let
  makeMullvadConfig = { publicKey, endpoint }: {
    address = [ "10.64.180.86/32" ];
    privateKeyFile =
      "${config.sops.secrets.stormveil-wireguard-mullvad-privkey.path}";
    peers = [{
      inherit publicKey endpoint;
      persistentKeepalive = 25;
      allowedIPs = [ "0.0.0.0/0" ];
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
      mullvad-ca28 = makeMullvadConfig {
        publicKey = "/ukKnQanjsX5MHbbhe7dJYIrSdPyP5UY7DMGStAznwk=";
        endpoint = "178.249.214.2:51820";
      };
      mullvad-ch9 = makeMullvadConfig {
        publicKey = "dV/aHhwG0fmp0XuvSvrdWjCtdyhPDDFiE/nuv/1xnRM=";
        endpoint = "193.32.127.70:51820";
      };
      mullvad-gb36 = makeMullvadConfig {
        publicKey = "tJVHqpfkV2Xgmd4YK60aoErSt6PmJKJjkggHNDfWwiU=";
        endpoint = "185.248.85.48:51820";
      };
      mullvad-us241 = makeMullvadConfig {
        publicKey = "AgaO2dCgD3SNEW8II143+pcMREFsnkoieay25nFLxDs=";
        endpoint = "23.226.135.50:51820";
      };
      mullvad-us252 = makeMullvadConfig {
        publicKey = "eR7g2lqwupyyhHWEIV67k/SEHRF2AtQ1bIac6m8ClmY=";
        endpoint = "143.244.47.91:51820";
      };
    };
    # use mullvad-us252 by default
    systemd.services.wg-quick-mullvad-ca28.wantedBy = lib.mkForce [ ];
    systemd.services.wg-quick-mullvad-ch9.wantedBy = lib.mkForce [ ];
    systemd.services.wg-quick-mullvad-gb36.wantedBy = lib.mkForce [ ];
    systemd.services.wg-quick-mullvad-us241.wantedBy = lib.mkForce [ ];
  };
}
