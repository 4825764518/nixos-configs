{ config, pkgs, ... }: {
  services.xserver.displayManager.lightdm.enable = true;
}
