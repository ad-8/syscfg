{
  flake.modules.homeManager.pkgs-gui =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        anki
        brave
        calibre
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
        # strawberry
        # TODO: remove once nixpkgs ships strawberry >= 1.2.29 (old Last.fm API key suspended)
        (strawberry.overrideAttrs (old: rec {
          version = "1.2.31";
          src = fetchFromGitHub {
            owner = "strawberrymusicplayer";
            repo = "strawberry";
            rev = version;
            hash = "sha256-U9qRaadhhHmzWBPS4QhofKAyVkZ+o7+emfNuRZRKWA0=";
          };
          buildInputs = old.buildInputs ++ [
            openssl
            libuchardet
            libsecret
          ];
          doCheck = false;
        }))
        thunderbird
        vivaldi
        vlc
        waypaper
      ];
    };
}
