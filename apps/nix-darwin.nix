# TODO: clean this up once nix-darwin has updated nix options to match nixos
{ config, lib, pkgs, ... }: {
  # Run GC if we have less than 10GiB free in the nix store
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    min-free = ${toString (10 * (1024 * 1024 * 1024))}
  '';

  nix.gc = {
    automatic = true;
    interval = { Hour = 24; };
    options = "--delete-older-than 30d";
  };

  nix.trustedUsers = [ "@wheel" ];

  environment.systemPackages = with pkgs; [ nixfmt rnix-lsp ];
}
