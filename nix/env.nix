{ nixpkgs ? import <nixpkgs> { } }:
let pkgs = import ./packages.nix { inherit nixpkgs; }; in
with pkgs;
{
  system = [
    coreutils
    gnugrep
  ];

  dev = [
    jq
    pls
    git
  ];

  lint = [
    pre-commit
    nixpkgs-fmt
    prettier
    shfmt
    shellcheck
  ];

}
