{ config, lib, pkgs, ... }:

with lib;
let
  homeCfg = config.profiles.home;
  cfg = config.profiles.home.shell;
in {
  options.profiles.home.shell = {
    enable = mkEnableOption "shell";
    backend = mkOption {
      default = "zsh";
      type = types.str;
    };
  };

  config = mkIf (homeCfg.enable && cfg.enable) {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.zsh = mkIf (cfg.backend == "zsh") {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;

      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        save = 50000;
      };

      oh-my-zsh = {
        enable = true;
        theme = "strug";
      };

      plugins = [
        {
          name = "nix-zsh-completions";
          file = "nix-zsh-completions.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "spwhitt";
            repo = "nix-zsh-completions";
            rev = "0.4.4";
            sha256 = "1n9whlys95k4wc57cnz3n07p7zpkv796qkmn68a50ygkx6h3afqf";
          };
        }
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.4.0";
            sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
          };
        }
      ];

      shellAliases = lib.optionalAttrs
        (homeCfg.terminal.enable && homeCfg.terminal.backend == "kitty") {
          ssh = "kitty +kitten ssh";
        };
    };
  };
}
