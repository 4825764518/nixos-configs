{ lib, useIpv6 ? true }:

{
  clientPeers = {
    firelinkPeer = {
      publicKey = "E8EtZnPIrYpEfq3G07pO2kHMR/ZR8hDw3QEa1Ab7vlI=";
      allowedIPs = [ "192.168.171.11/32" "fd4e:acd2:410e:0011::/64" ];
      persistentKeepalive = 25;
    };

    kilnPeer = {
      publicKey = "1RS2Fub/Tl7jEFG8jlVici/B3Se+uwCa0fSpnerPSQw=";
      allowedIPs = [ "192.168.171.10/32" ];
      persistentKeepalive = 25;
    };

    stormveilPeer = {
      publicKey = "yVSQqYaAFhUWVWdgRM1mRG79htZ91jL37gciPSuJ4S0=";
      allowedIPs = [ "192.168.171.20/32" "fd4e:acd2:410e:0020::/64" ];
      persistentKeepalive = 25;
    };

    stormveilWindowsPeer = {
      publicKey = "cnY4vr+LJiR7Mar+oID8I2r+vll8RexI055DKIHVNn0=";
      allowedIPs = [ "10.64.180.86/32" "fc00:bbbb:bbbb:bb01::1:b455/128" ];
      persistentKeepalive = 25;
    };

    interloperPeer = {
      publicKey = "E3NUKOODIk6gSm85LtfzLJUwwXcKOeeli8dihRDgfQM=";
      allowedIPs = [ "10.67.238.34/32" "fc00:bbbb:bbbb:bb01::4:ee21/128" ];
      persistentKeepalive = 25;
    };

    iphonePeer = {
      publicKey = "Pa7NHFgi2r5JKD8LlhMk+3mctmbMcwXggf3pvIrebxQ=";
      allowedIPs = [ "10.64.57.118/32" ];
      persistentKeepalive = 25;
    };

    iphoneProPeer = {
      publicKey = "sL3ePIYYuOLaWmN0xkDIftZTKhClXIO44Rszykp5gmU=";
      allowedIPs = [ "10.64.73.186/32" "fc00:bbbb:bbbb:bb01::1:49b9/128" ];
      persistentKeepalive = 25;
    };
  };

  serverPeers = {
    ainselPeer = {
      publicKey = "eY/49qo0cPnTAw6Kl0AwlGE/jU+jrkdCNHXVtSNvfn0=";
      allowedIPs = [ "192.168.172.20/32" "fdc3:62d8:4c3a:0020::/64" ];
      endpoint =
        if useIpv6 then "2a01:4f9:6a:206b::1:51820" else "65.21.233.174:51820";
      persistentKeepalive = 25;
    };

    leyndellPeer = {
      publicKey = "+YVWahC4Rd7CZyWyaxYO1iyvOoFV4yUK4OfXWSbF+Ac=";
      allowedIPs = [ "192.168.172.10/32" "fdc3:62d8:4c3a:0010::/64" ];
      endpoint =
        if useIpv6 then "2a01:4f9:1a:991f::1:51820" else "65.108.197.14:51820";
      persistentKeepalive = 25;
    };

    mornePeer = withHetznerRoutes: {
      publicKey = "+y5ZjN6GToEbF3fwRnwJJH+tDZsgEvsJXoKyno0SfVg=";
      allowedIPs = [
        "192.168.171.0/24"
        "10.67.238.34/32"
        "10.64.57.118/32"
        "10.64.73.186/32"
        "10.64.180.86/32"
        "fd4e:acd2:410e::/48"
        "fd9f:b343:6ef8::/48"
      ] ++ lib.optionals withHetznerRoutes [
        "192.168.172.0/24"
        "fdc3:62d8:4c3a::/48"
      ];
      endpoint = if useIpv6 then
        "2607:5300:60:3fcb::2:51820"
      else
        "51.222.128.114:51820";
      persistentKeepalive = 25;
    };

    ovhPeer = {
      publicKey = "Mo1wqAe5SNixIikRSlVY9DpT5Nz19mZenWym3voa0TM=";
      allowedIPs = [ "192.168.170.0/24" ];
      endpoint =
        if useIpv6 then "2607:5300:60:3fcb::1:51820" else "192.99.14.203:51820";
      persistentKeepalive = 25;
    };
  };
}
