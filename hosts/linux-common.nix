{ config, pkgs, ... }:

{
  imports = [ ../apps/common.nix ../apps/nix.nix ];

  boot.kernelParams =
    [ "zswap.enabled=1" "zswap.compressor=lz4" "zswap.zpool=zbud" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.fstrim.enable = true;
  services.fstrim.interval = "weekly";

  environment.systemPackages = with pkgs; [
    btrfs-progs
    compsize
    smartmontools
    xfsprogs
  ];

  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;
}
