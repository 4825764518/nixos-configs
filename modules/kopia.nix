{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.kopia;

  localRepositoryType = types.submodule ({ ... }: {
    options = {
      path = mkOption {
        description = "Path to the local repository";
        type = types.str;
        example = "/foo/some-repository";
      };
      passwordFile = mkOption {
        description = "TODO";
        type = types.str;
        example = "/foo/.secrets/some-password";
      };
    };
  });

  b2RepositoryType = types.submodule ({ ... }: {
    options = {
      bucket = mkOption {
        description = "TODO";
        type = types.str;
        example = "TODO";
      };

      applicationKeyId = mkOption {
        description = "TODO";
        type = types.str;
        example = "TODO";
      };

      applicationKeyFile = mkOption {
        description = "TODO";
        type = types.str;
        example = "/foo/.secrets/some-password";
      };
    };
  });
in {
  options.services.kopia = {
    enable = mkEnableOption "kopia";
    localRepositories = mkOption {
      description = "TODO";
      default = [ ];
      example = "TODO";
      type = types.listOf localRepositoryType;
    };
    b2Repositories = mkOption {
      description = "TODO";
      default = [ ];
      example = "TODO";
      type = types.listOf b2RepositoryType;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ kopia ];

    # Oneshot service to connect to all configured local repositories
    systemd.services.kopia-local-repositories =
      mkIf (cfg.localRepositories != [ ]) {
        description = "Connect kopia to local repositories";
        after = [ "remote-fs.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig.Type = "oneshot";
        script = (builtins.concatStringsSep "\n" (builtins.map (localRepoDef:
          ''
            ${pkgs.kopia}/bin/kopia connect filesystem --path="${localRepoDef.path}" --password="$(cat ${localRepoDef.passwordFile})"'')
          cfg.localRepositories));
      };

    systemd.services.kopia-b2-repositories = mkIf (cfg.b2Repositories != [ ]) {
      description = "Connect kopia to b2 repositories";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script = (builtins.concatStringsSep "\n" (builtins.map (b2RepoDef:
        ''
          ${pkgs.kopia}/bin/kopia connect b2 --bucket="${b2RepoDef.bucket}" --keyId="${b2RepoDef.applicationKeyId}" --key="$(cat ${b2RepoDef.applicationKeyFile})"'')
        cfg.b2Repositories));
    };
  };
}
