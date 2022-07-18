{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" "msr" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/nvme0n1p3";
    fsType = "btrfs";
    options =
      [ "ssd" "compress-force=zstd:1" "space_cache=v2" "discard=async" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FBA2-F4FC";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/b536cf66-e0db-4501-9f92-31b8f129d263"; }
    { device = "/dev/disk/by-uuid/f97ce38f-3b08-4ace-80e2-f2eefa1d9c34"; }
  ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = lib.mkDefault false;
  networking.interfaces.enp35s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
