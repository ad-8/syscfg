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
    {
      # en_US.dic is UTF-8 already; pass through (tail drops the word-count line).
      tail -n +2 ${pkgs.hunspellDicts.en_US}/share/hunspell/en_US.dic
      # de_DE.dic ships as ISO-8859-1; convert so umlauts (ä ö ü ß) are valid UTF-8.
      tail -n +2 ${pkgs.hunspellDicts.de_DE}/share/hunspell/de_DE.dic \
        | ${pkgs.glibc.bin}/bin/iconv -f ISO-8859-1 -t UTF-8
    } \
      | sed -e 's:[/[:space:]].*::' -e '/^$/d' \
      | LC_ALL=C sort -u > "$out/share/dict/words"
  '';
in
{
  options = {
    configEmacs.enable = lib.mkEnableOption "Enable Emacs support";
  };

  config = lib.mkIf config.configEmacs.enable {
    xdg.dataFile."dict/words".source = "${ispellWordList}/share/dict/words";

    home.packages = with pkgs; [
      multimarkdown # to enable markdown-preview in doom emacs

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
