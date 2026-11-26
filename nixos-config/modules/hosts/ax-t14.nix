{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-t14 = inputs.nixpkgs-stable.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = with modules.nixos; [
      base
      core
      home-manager
      mango
      audio
      firefox
      keyd
      workstation
      zfs
      ../../hosts/ax-t14/configuration.nix
      {
        home-manager.users.ax.imports = [ modules.homeManager.ax ];
      }
    ];
  };
}
