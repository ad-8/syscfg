{ config, ... }:

{
  flake.modules.homeManager.ax.imports = with config.flake.modules.homeManager; [
    btop
    fastfetch
    fish
    foot
    git
    starship
    tmux
    vim
  ];
}
