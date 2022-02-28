{ config, pkgs, ... }: {
  homebrew = {
    casks = [
      "altserver"
      "db-browser-for-sqlite"
      "docker"
      "dotnet-sdk"
      "flameshot"
      "geekbench"
      "ghidra"
      "gimp"
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
