{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-vm = inputs.nixpkgs-stable.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = with modules.nixos; [
      base
      home-manager
      ../../hosts/ax-vm/configuration.nix
      {
        home-manager.users.ax.imports = [
          ../../hosts/ax-vm/home.nix
          modules.homeManager.git
        ];
      }
    ];
  };
}
