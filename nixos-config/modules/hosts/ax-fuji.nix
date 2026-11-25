{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-fuji = inputs.nixpkgs-stable.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = with modules.nixos; [
      base
      starship
      ../../hosts/ax-fuji/configuration.nix
    ];
  };
}
