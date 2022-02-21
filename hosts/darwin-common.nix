{ config, pkgs, ... }:

{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  system.defaults.dock = {
    autohide = true;
    autohide-delay = "0.0001"; # "0.24";
    launchanim = true;
    mineffect = "suck";
    orientation = "left";
    show-process-indicators = true;
    showhidden = true;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    QuitMenuItem = true;
    _FXShowPosixPathInTitle = true;
  };

  system.defaults.trackpad = { Clicking = false; };

  # Disable inverted scrolling
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.NSGlobalDomain."com.apple.trackpad.enableSecondaryClick" =
    true;
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = "1";
}
