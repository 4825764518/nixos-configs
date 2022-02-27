{ config, pkgs, ... }:

{
    imports = [
    ../apps/common.nix
    ../apps/nix.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
