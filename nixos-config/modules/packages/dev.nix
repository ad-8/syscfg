{
  flake.modules.homeManager.pkgs-dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        clojure
        clojure-lsp
        geckodriver
        gh
        joker
        jq
        leiningen
        nil # nix language server
        nixfmt
        sqlitebrowser
        youplot # cli plots

        # TODO evaluate rust pkgs
        cargo
        cargo-outdated
        clippy
        gcc
        rust-analyzer
        rustc
        rustfmt

        # TODO eval Gleam
        gleam
        beamPackages.erlang
        beamPackages.rebar3
      ];
    };
}
