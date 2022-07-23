{ config, pkgs, ... }: {
  # Run GC if we have less than 10GiB free in the nix store
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    min-free = ${toString (10 * (1024 * 1024 * 1024))}
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    persistent = true;
  };

  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [ "@wheel" ];
  };

  environment.systemPackages = with pkgs; [ nixfmt ];
}
