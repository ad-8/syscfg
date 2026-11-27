{ inputs, ... }:

{
  flake.modules.nixos.agenix = {
    imports = [ inputs.agenix.nixosModules.default ];
  };
}
