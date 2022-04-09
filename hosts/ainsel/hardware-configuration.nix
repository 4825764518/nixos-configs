{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "zroot/root/nix";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5E56-C2F0";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/cb05744c-273d-409c-b287-ec6cf4298a43"; }
    { device = "/dev/disk/by-uuid/920e57a3-c320-4e70-a34a-08250d9944ff"; }
    { device = "/dev/disk/by-uuid/18af6475-ab1c-4e80-8c5a-4ae7a543450b"; }
    { device = "/dev/disk/by-uuid/885380cb-37da-4b91-a4d4-908db5b28088"; }
  ];

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = lib.mkDefault false;
  networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
