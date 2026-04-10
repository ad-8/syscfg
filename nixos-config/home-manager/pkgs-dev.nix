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
      helix
      jq
      leiningen
      nil # nix language server
      nixd # better nix language server, but doom emacs seems to support nil (and an obscure option) only
      nixfmt
      semgrep # needed for clojure lsp and others in emacs
      sqlitebrowser
      vscodium
      youplot # cli plots
    ];
  };
}
