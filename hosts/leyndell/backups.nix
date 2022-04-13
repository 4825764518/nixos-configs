{ config, pkgs, ... }:

let
  postgresDumpScript = name: ''
    rm -fv /opt/containers/synapse-postgres/dump/${name}/synapse-postgres-dump.sql.zstd
    echo "Removed old dumps"
    ${config.virtualisation.docker.package}/bin/docker exec synapse-postgres pg_dumpall --username=synapse --file=/dump/${name}/synapse-postgres-dump.sql
    echo "Finished postgres dump, compressing with zstd"
    ${pkgs.zstd}/bin/zstd --compress -9 --rm /opt/containers/synapse-postgres/dump/${name}/synapse-postgres-dump.sql 
    echo "Finished compressing postgres dump"
  '';
in {
  config = {
    sops.secrets.leyndell-restic-ainsel-s3-environment = {
      sopsFile = ../../secrets/leyndell/passwords.yaml;
    };
    sops.secrets.leyndell-restic-ainsel-s3-password = {
      sopsFile = ../../secrets/leyndell/passwords.yaml;
    };
    sops.secrets.leyndell-restic-b2-environment = {
      sopsFile = ../../secrets/leyndell/passwords.yaml;
    };
    sops.secrets.leyndell-restic-b2-password = {
      sopsFile = ../../secrets/leyndell/passwords.yaml;
    };
    services.restic.backups = {
      ainselBackup = {
        environmentFile =
          "${config.sops.secrets.leyndell-restic-ainsel-s3-environment.path}";
        initialize = true;
        passwordFile =
          "${config.sops.secrets.leyndell-restic-ainsel-s3-password.path}";
        paths = [
          "/home"
          "/root"
          "/opt/containers/synapse"
          "/opt/containers/synapse-postgres/dump/ainsel"
        ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 100"
        ];
        extraOptions = [ "verbose=1" ];
        repository = "s3:https://s3.ainsel.kenzi.dev/leyndell-backups";
        timerConfig = { OnCalendar = "daily"; };
      };
      b2Backup = {
        environmentFile =
          "${config.sops.secrets.leyndell-restic-b2-environment.path}";
        initialize = true;
        passwordFile =
          "${config.sops.secrets.leyndell-restic-b2-password.path}";
        paths = [
          "/home"
          "/root"
          "/opt/containers/synapse"
          "/opt/containers/synapse-postgres/dump/b2"
        ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 100"
        ];
        extraOptions = [ "verbose=1" ];
        repository = "b2:restic-leyndell:/";
        timerConfig = { OnCalendar = "daily"; };
      };
    };

    systemd.services."restic-backups-ainselBackup".preStart =
      postgresDumpScript "ainsel";
    systemd.services."restic-backups-b2backup".preStart =
      postgresDumpScript "b2";
  };
}
