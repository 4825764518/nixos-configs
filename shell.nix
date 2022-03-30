{ pkgs }:

pkgs.mkShell { buildInputs = [ pkgs.nixpkgs-fmt pkgs.sops ]; }
