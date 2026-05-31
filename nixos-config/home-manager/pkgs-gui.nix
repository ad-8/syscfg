{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    pkgsGui.enable = lib.mkEnableOption "Enable GUI pkgs";
  };

  config = lib.mkIf config.pkgsGui.enable {
    home.packages = with pkgs; [
      anki
      brave
      gimp3
      kdePackages.okular
      keepassxc
      libreoffice-still
      megasync # compiles from src!
      mpv
      pavucontrol
      picard
      protonmail-bridge-gui
      qalculate-gtk
      qbittorrent
      qutebrowser
      signal-desktop
      strawberry
      thunderbird
      vlc
      waypaper
      mousepad
      ristretto
    ];
  };
}
