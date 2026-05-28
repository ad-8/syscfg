{
  pkgs,
  lib,
  config,
  ...
}:

let
  # Clean, sorted word list for Emacs ispell word completion
  # (ispell-alternate-dictionary). NixOS has no /usr/share/dict/words, so this
  # is built from the hunspell dictionaries already installed below; it strips
  # the affix flags / morphology so each line is a plain word. Bilingual to
  # match the en_US,de_DE spell setup. Symlinked to ~/.local/share/dict/words
  # via xdg.dataFile, which the Doom config references by that fixed path.
  ispellWordList = pkgs.runCommand "ispell-wordlist" { } ''
    mkdir -p "$out/share/dict"
    for d in ${pkgs.hunspellDicts.en_US}/share/hunspell/en_US.dic \
             ${pkgs.hunspellDicts.de_DE}/share/hunspell/de_DE.dic; do
      tail -n +2 "$d"          # drop the leading word-count line
    done \
      | sed -e 's:[/[:space:]].*::' -e '/^$/d' \
      | LC_ALL=C sort -u > "$out/share/dict/words"
  '';
in
{
  options = {
    pkgsExtra.enable = lib.mkEnableOption "Enable extra pkgs";
  };

  config = lib.mkIf config.pkgsExtra.enable {
    xdg.dataFile."dict/words".source = "${ispellWordList}/share/dict/words";

    home.packages = with pkgs; [
      age
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
