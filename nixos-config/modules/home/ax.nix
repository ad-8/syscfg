{ config, ... }:

{
  flake.modules.homeManager.ax.imports = with config.flake.modules.homeManager; [
    foot
    starship
  ];
}
