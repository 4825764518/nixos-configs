{ config, pkgs, ... }:

{
  imports = [ ../apps/common.nix ../apps/nix.nix ];

  boot.initrd.kernelModules = [ "zstd" "z3fold" ];
  boot.kernelParams =
    [ "zswap.enabled=1" "zswap.compressor=zstd" "zswap.zpool=z3fold" ];
  boot.kernelPatches = [{
    name = "zswap";
    patch = null;
    extraConfig = ''
      Z3FOLD y
      CRYPTO_ZSTD y
    '';
  }];
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
}
