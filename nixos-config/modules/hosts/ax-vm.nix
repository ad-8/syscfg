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
      core
      home-manager
      audio
      ../../hosts/ax-vm/configuration.nix
      {
        home-manager.users.ax.imports = with modules.homeManager; [
          base
          emacs
          git
          pkgs-core
        ];
      }
    ];
  };
}
