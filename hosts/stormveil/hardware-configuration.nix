{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" "msr" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/56bc1b4a-6203-48f2-ac8f-5dd942518bd7";
    fsType = "btrfs";
    options =
      [ "ssd" "compress-force=zstd:1" "space_cache=v2" "discard=async" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/2b0fa2b4-809c-42e6-89fd-e15f0abe2b63";
    fsType = "btrfs";
    options =
      [ "ssd" "compress-force=zstd:9" "space_cache=v2" "discard=async" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/934C-9FE2";
    fsType = "vfat";
  };

  fileSystems."/hangar" = {
    device = "10.10.31.10:/hangar";
    fsType = "nfs";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/05a4d4bc-b839-47fe-8e75-b17202a5b43d"; }];

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
