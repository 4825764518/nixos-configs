{ config, pkgs, ... }: {
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  # this is required until nix 2.4 is released
  nix.package = pkgs.nixUnstable;

  environment.systemPackages = with pkgs; [ nixfmt ];
}
