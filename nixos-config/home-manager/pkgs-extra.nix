{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    pkgsExtra.enable = lib.mkEnableOption "Enable extra pkgs";
  };

  config = lib.mkIf config.pkgsExtra.enable {
    home.packages = with pkgs; [
      btop
      chafa
      gum
      imagemagick
      inxi # Full featured CLI system information tool
      iotop-c
      lm_sensors # provides `sensors` cmd to show cpu temp etc.
      multimarkdown # to enable markdown-preview in doom emacs
      pciutils # lspci and more
      pdftk
      smartmontools
      steam-run
      unzip
      usbutils # lsusb and more
      wireguard-tools

      # emacs dirvish
      ffmpegthumbnailer
      mediainfo
      poppler-utils # contains pdftoppm, needed by emacs dirvish
      vips

      # emacs ispell (which can use aspell or hunspell)
      # (aspellWithDicts (dicts: with dicts; [ en de en-computers en-science ]))
      hunspell
      hunspellDicts.de_DE
      hunspellDicts.en_US

      # required for the emacs everywhere for wayland script by Thanos Apollo
      wtype
    ];
  };
}
