{ config, pkgs, ... }: {
  homebrew = {
    # TODO: manage python with nix once jellyfin-mpv-shim is fixed on darwin
    brews = [ "python@3.9" "wireguard-tools" ];
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
      "mpv"
      "postman"
      "raycast"
      "rectangle"
      "signal"
      "spotify"
      "steam"
      "telegram"
      "temurin"
      "thunderbird"
      "visual-studio-code"
    ];
    cleanup = "zap";
    enable = true;
    taps = [ "homebrew/bundle" "homebrew/cask" "homebrew/core" ];
  };
}
