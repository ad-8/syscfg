{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-bee = inputs.nixpkgs-stable.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = with modules.nixos; [
      base
      home-manager
      mango
      audio
      clamav
      distrobox
      firefox
      gaming
      printing
      virtman
      workstation
      ../../hosts/ax-bee/configuration.nix
      {
        home-manager.users.ax.imports = [
          ../../hosts/ax-bee/home.nix
          modules.homeManager.ax
        ];
      }
    ];
  };
}
