{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ xmrig-mo ];

  systemd.services.xmrig = {
    # wantedBy = [ "multi-user.target" ];
    wantedBy = [ ];
    after = [ "network.target" ];
    description = "Start xmrig-mo";
    serviceConfig = {
      Type = "forking";
      GuessMainPID = "no";
      ExecStart =
        "${pkgs.xmrig-mo}/bin/xmrig -c /etc/xmrig-config.json -l /var/log/xmrig.log -B";
      Restart = "always";
      User = "root";
    };
  };
}
