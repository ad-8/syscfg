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
      # megasync # this compiles from src! TODO broken after upgrading to 25.11 (won't build)
      anki
      brave
      gimp3
      kdePackages.okular
      keepassxc
      libreoffice-still
      localsend
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
      xfce.mousepad
      xfce.ristretto
    ];
  };
}
