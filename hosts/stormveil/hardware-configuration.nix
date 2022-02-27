{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/56bc1b4a-6203-48f2-ac8f-5dd942518bd7";
    fsType = "btrfs";
    options =
      [ "ssd" "compress-force=zstd:1" "space_cache=v2" "discard=async" ];
  };

  fileSystems."/mnt/qlc-nvme" = {
    device = "/dev/disk/by-uuid/02f1e732-3adc-4cb7-bf00-78cba0fe16ff";
    fsType = "btrfs";
    options =
      [ "ssd" "compress-force=zstd:3" "space_cache=v2" "discard=async" ];
  };

  fileSystems."/mnt/mx500-raid" = {
    device = "/dev/disk/by-id/ata-CT1000MX500SSD1_2045E4C5B3E1";
    fsType = "btrfs";
    options =
      [ "ssd" "compress-force=zstd:5" "space_cache=v2" "discard=async" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/934C-9FE2";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/05a4d4bc-b839-47fe-8e75-b17202a5b43d"; }];

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
