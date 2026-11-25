{ config, ... }:

{
  flake.modules.homeManager.ax.imports = with config.flake.modules.homeManager; [
    auth-agent
    base
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
    tealdeer
    tmux
    vim
    webapps
  ];
}
