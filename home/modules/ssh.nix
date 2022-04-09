{ config, lib, pkgs, ... }:

let defaultTrustedOptions = { forwardAgent = true; };
in {
  programs.ssh = {
    enable = true;
    compression = true;

    matchBlocks = {
      # Enable ssh agent forwarding for trusted servers
      "192.168.169.*,192.168.171.*,192.99.14.203,51.222.128.114" =
        defaultTrustedOptions;

      "firelink" = defaultTrustedOptions // {
        hostname = "192.168.169.11";
        user = "shrinekeeper";
      };
      "kiln" = defaultTrustedOptions // {
        hostname = "192.168.169.10";
        user = "root";
      };
      "leyndell" = defaultTrustedOptions // {
        hostname = "65.108.197.14";
        user = "esgar";
      };
      "morne" = defaultTrustedOptions // {
        hostname = "51.222.128.114";
        user = "misbegotten";
      };
      "ovh" = defaultTrustedOptions // {
        hostname = "192.99.14.203";
        user = "kenzie";
      };
      "router" = defaultTrustedOptions // {
        hostname = "192.168.169.1";
        user = "kenzie";
      };
      "stormveil" = defaultTrustedOptions // {
        hostname = "192.168.169.20";
        user = "kenzie";
      };
    };
  };
}
