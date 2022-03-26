{ config, pkgs, ... }: {
  homebrew = {
    casks = [
      "altserver"
      "docker"
      "dotnet-sdk"
      "flameshot"
      "geekbench"
      "ghidra"
      "jellyfin-media-player"
      "jetbrains-toolbox"
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
