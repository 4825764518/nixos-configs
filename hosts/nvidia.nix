{ config, lib, ... }:

{
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;

  services.xserver.exportConfiguration = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver.deviceSection = ''
    VendorName "NVIDIA Corporation"
    Option "Coolbits" "28"
  '';

  services.xserver.serverLayoutSection = ''
    Screen 0 "Screen-nvidia[0]" 0 0
  '';

  # TODO: move to stormveil config if multiple machine-specific nvidia configs are needed
  services.xserver.monitorSection = ''
    ModelName "Acer VG270U P"
    HorizSync 222.0 - 222.0
    VertRefresh 40.0 - 144.0
  '';

  services.xserver.screenSection = ''
    DefaultDepth 24
    Option "Stereo" "0"
    Option "nvidiaXineramaInfoOrder" "DFP-1"
    Option "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On, AllowGSYNCCompatible=On}"
    Option "SLI" "Off"
    Option "MultiGPU" "Off"
    Option "BaseMosaic" "off"
    SubSection "Display"
        Depth       24
    EndSubSection
  '';
}
