{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-t14 = inputs.nixpkgs-stable.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = with modules.nixos; [
      base
      home-manager
      mango
      audio
      firefox
      workstation
      ../../hosts/ax-t14/configuration.nix
      {
        home-manager.users.ax.imports = [
          ../../hosts/ax-t14/home.nix
          modules.homeManager.ax
        ];
      }
    ];
  };
}
