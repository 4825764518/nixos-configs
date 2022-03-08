{ config, osConfig, lib, pkgs, ... }:

{
  config.programs.gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
    publicKeys = [{ source = osConfig.sops.secrets.common-gpg-keyring.path; }];
  };
}
