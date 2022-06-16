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

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;

      settings = {
        # This line replaces add_newline = false
        add_newline = false;

        format =
          "$username$hostname$directory$shell$shlvl$git_branch$nix_shell$git_commit$git_state$git_status$cmd_duration$jobs$status$character";

        # indicator if bash
        shell = {
          disabled = false;
          zsh_indicator = "";
          bash_indicator = "bash ";
          format = "[$indicator]($style)";
        };

        shlvl = {
          disabled = false;
          symbol = "↕️";
        };

        status = { disabled = false; };

        directory = {
          disabled = false;
          truncation_length = 1;
          fish_style_pwd_dir_length = 1;
          truncate_to_repo = false;
        };

        hostname = {
          ssh_only = false;
          style = "#ff66ff";
          format = "[@$hostname]($style):";
        };

        line_break = { disabled = true; };

        aws = {
          format =
            "\\[[$symbol($profile)(\\($region\\))(\\[$duration\\])]($style)\\]";
        };

        c = { format = "\\[[$symbol($version(-$name))]($style)\\]"; };

        cmake = { format = "\\[[$symbol($version)]($style)\\]"; };

        cmd_duration = {
          disabled = false;
          format = "\\[[⏱ $duration]($style)\\]";
          min_time = 10000;
        };

        cobol = { format = "\\[[$symbol($version)]($style)\\]"; };

        conda = { format = "\\[[$symbol$environment]($style)\\]"; };

        crystal = { format = "\\[[$symbol($version)]($style)\\]"; };

        dart = { format = "\\[[$symbol($version)]($style)\\]"; };

        deno = { format = "\\[[$symbol($version)]($style)\\]"; };

        docker_context = { format = "\\[[$symbol$context]($style)\\]"; };

        dotnet = { format = "\\[[$symbol($version)(🎯 $tfm)]($style)\\]"; };

        elixir = {
          format = "\\[[$symbol($version \\(OTP $otp_version\\))]($style)\\]";
        };

        elm = { format = "\\[[$symbol($version)]($style)\\]"; };

        erlang = { format = "\\[[$symbol($version)]($style)\\]"; };

        gcloud = {
          format = "\\[[$symbol$account(@$domain)(\\($region\\))]($style)\\]";
        };

        git_branch = {
          format = "\\[[$symbol$branch]($style)\\]";
          ignore_branches = [ "master" "main" ];
        };

        git_status = { format = "([\\[$all_status$ahead_behind\\]]($style))"; };

        golang = { format = "\\[[$symbol($version)]($style)\\]"; };

        haskell = { format = "\\[[$symbol($version)]($style)\\]"; };

        helm = { format = "\\[[$symbol($version)]($style)\\]"; };

        hg_branch = { format = "\\[[$symbol($version)]($style)\\]"; };

        java = { format = "\\[[$symbol($version)]($style)\\]"; };

        julia = { format = "\\[[$symbol($version)]($style)\\]"; };

        kotlin = { format = "\\[[$symbol($version)]($style)\\]"; };

        kubernetes = {
          format = "\\[[$symbol$context( \\($namespace\\))]($style)\\]";
        };

        lua = { format = "\\[[$symbol($version)]($style)\\]"; };

        memory_usage = { format = "\\[$symbol[$ram( | $swap)]($style)\\]"; };

        nim = { format = "\\[[$symbol($version)]($style)\\]"; };

        nix_shell = {
          disabled = false;
          format = "\\[[$symbol$state( \\($name\\))]($style)\\]";
          impure_msg = "";
          pure_msg = "";
          symbol = "❄️";
        };

        nodejs = { format = "\\[[$symbol($version)]($style)\\]"; };

        ocaml = {
          format =
            "\\[[$symbol($version)(\\($switch_indicator$switch_name\\))]($style)\\]";
        };

        openstack = {
          format = "\\[[$symbol$cloud(\\($project\\))]($style)\\]";
        };

        package = { format = "\\[[$symbol$version]($style)\\]"; };

        perl = { format = "\\[[$symbol($version)]($style)\\]"; };

        php = { format = "\\[[$symbol($version)]($style)\\]"; };

        pulumi = { format = "\\[[$symbol$stack]($style)\\]"; };

        purescript = { format = "\\[[$symbol($version)]($style)\\]"; };

        python = {
          format =
            "\\[[\${symbol}\${pyenv_prefix}(\${version})(\\($virtualenv\\))]($style)\\]";
        };

        red = { format = "\\[[$symbol($version)]($style)\\]"; };

        ruby = { format = "\\[[$symbol($version)]($style)\\]"; };

        rust = { format = "\\[[$symbol($version)]($style)\\]"; };

        scala = { format = "\\[[$symbol($version)]($style)\\]"; };

        spack = { format = "\\[[$symbol$environment]($style)\\]"; };

        sudo = { format = "\\[[as $symbol]\\]"; };

        swift = { format = "\\[[$symbol($version)]($style)\\]"; };

        terraform = { format = "\\[[$symbol$workspace]($style)\\]"; };

        time = { format = "\\[[$time]($style)\\]"; };

        username = {
          disabled = false;
          show_always = true;
          style_user = "#ff66ff";
          style_root = "bold fg:red";
          format = "\\[[$user]($style)\\]";
        };

        vagrant = { format = "\\[[$symbol($version)]($style)\\]"; };

        vlang = { format = "\\[[$symbol($version)]($style)\\]"; };

        zig = { format = "\\[[$symbol($version)]($style)\\]"; };
      };
    };

    programs.bash = { enable = true; };

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
