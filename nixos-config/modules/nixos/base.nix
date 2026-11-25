{ inputs, ... }:

{
  flake.modules.nixos.base = {
    imports = [
      inputs.agenix.nixosModules.default
      inputs.mangowm.nixosModules.mango
    ];
  };
}
