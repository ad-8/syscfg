{ config, ... }:

{
  # megasync, qt and secret-service exist as features but are off on purpose
  flake.modules.homeManager.workstation.imports = with config.flake.modules.homeManager; [
    auth-agent
    btop
    clojure
    doom
    emacs
    fastfetch
    fish
    foot
    git
    gtk
    mime
    mpv
    pkgs-core
    pkgs-dev
    pkgs-extra
    pkgs-gui
    restic
    starship
    swappy
    swayimg
    tealdeer
    tmux
    vim
    webapps
  ];
}
