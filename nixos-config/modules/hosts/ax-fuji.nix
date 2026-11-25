{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-fuji = inputs.nixpkgs-stable.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = with modules.nixos; [
      base
      btop
      fastfetch
      fish
      git
      starship
      tmux
      vim
      ../../hosts/ax-fuji/configuration.nix
    ];
  };
}
