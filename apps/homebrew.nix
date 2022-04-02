{ config, pkgs, ... }: {
  homebrew = {
    brews = [ "wireguard-tools" ];
    casks = [
      "altserver"
      "db-browser-for-sqlite"
      "docker"
      "dotnet-sdk"
      "eloston-chromium"
      "firefox"
      "flameshot"
      "geekbench"
      "ghidra"
      "gimp"
      "inkscape"
      "jellyfin-media-player"
      "jetbrains-toolbox"
      "keepassxc"
      "libreoffice"
      "postman"
      "raycast"
      "rectangle"
      "spotify"
      "steam"
      "temurin"
      "visual-studio-code"
    ];
    cleanup = "zap";
    enable = true;
    taps = [ "homebrew/bundle" "homebrew/cask" "homebrew/core" ];
  };
}
