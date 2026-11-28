{
  flake.modules.homeManager.pkgs-gui =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        anki
        brave
        calibre
        dillo
        gimp3
        kdePackages.okular
        keepassxc
        libreoffice-fresh
        mousepad
        pavucontrol
        picard
        pika-backup
        protonmail-bridge-gui
        qalculate-gtk
        qbittorrent
        signal-desktop
        thunderbird
        vivaldi
        vlc
        waypaper
      ];
    };
}
