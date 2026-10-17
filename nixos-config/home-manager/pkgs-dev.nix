{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    pkgsDev.enable = lib.mkEnableOption "Enable dev pkgs";
  };

  config = lib.mkIf config.pkgsDev.enable {
    home.packages = with pkgs; [
      clojure
      clojure-lsp
      direnv
      geckodriver
      gh
      janet
      joker
      jq
      leiningen
      nil # nix language server
      nixfmt
      semgrep # needed for clojure lsp and others in emacs
      sqlitebrowser
      vscodium
      youplot # cli plots
    ];
  };
}
