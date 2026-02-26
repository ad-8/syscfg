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
      gnome-disk-utility
      kdePackages.okular
      keepassxc
      kitty
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
      ungoogled-chromium
      vlc
      xfce.mousepad
      xfce.ristretto
    ];
  };
}
