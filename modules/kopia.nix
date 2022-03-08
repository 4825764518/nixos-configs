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
in {
  options.services.kopia = {
    enable = mkEnableOption "kopia";
    localRepositories = mkOption {
      description = "TODO";
      default = [ ];
      example = "TODO";
      type = types.listOf localRepositoryType;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ kopia ];

    # Oneshot service to connect to all configured local repositories
    systemd.services.kopia-local-repositories = {
      description = "Connect kopia to local repositories";
      after = [ "remote-fs.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script = (builtins.concatStringsSep "\n" (builtins.map (localRepoDef:
        ''
          ${pkgs.kopia}/bin/kopia connect filesystem --path "${localRepoDef.path}" --password "$(cat ${localRepoDef.passwordFile})"'')
        cfg.localRepositories));
    };
  };
}
