{ pkgs, ... }:

{
  programs.mangohud.enable = true;

  home.packages = with pkgs; [
    mu
    isync
  ];
}
