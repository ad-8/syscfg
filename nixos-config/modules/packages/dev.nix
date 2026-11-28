{
  flake.modules.homeManager.pkgs-dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        geckodriver
        gh
        joker
        jq
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
