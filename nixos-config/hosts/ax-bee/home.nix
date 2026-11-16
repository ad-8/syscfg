{ pkgs, ... }:

{
  imports = [
    ../../home-manager/default.nix
  ];

  programs.mangohud.enable = true;

  home.packages = with pkgs; [
    mu
    isync
  ];
}
