{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ gwe ];

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;

  services.xserver.exportConfiguration = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver.config = ''
    Section "Device"
      Identifier     "Device0"
      Driver         "nvidia"
      VendorName     "NVIDIA Corporation"
      BoardName      "NVIDIA GeForce RTX 3080 Ti"
      BusID          "PCI:39:0:0"
      Option         "Coolbits" "28"
    EndSection

    Section "Device"
     Identifier     "Device1"
     Driver         "nvidia"
     VendorName     "NVIDIA Corporation"
     BoardName      "NVIDIA GeForce RTX 2070"
     BusID          "PCI:40:0:0"
     Option         "Coolbits" "28"
    EndSection

    Section "Monitor"
      Identifier     "Monitor0"
      VendorName     "Unknown"
      ModelName      "Acer VG270U P"
      HorizSync       222.0 - 222.0
      VertRefresh     40.0 - 144.0
    EndSection

    Section "Screen"
      Identifier     "Screen0"
      Device         "Device0"
      Monitor        "Monitor0"
      DefaultDepth    24
      Option         "Stereo" "0"
      Option         "nvidiaXineramaInfoOrder" "DFP-1"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
      SubSection     "Display"
          Depth       24
      EndSubSection
    EndSection

    Section "ServerLayout"
      Identifier "Layout-custom"
      Screen 0 "Screen0" 0 0
    EndSection
  '';

  services.xserver.serverFlagsSection = ''
    Option "DefaultServerLayout" "Layout-custom"
  '';
}
