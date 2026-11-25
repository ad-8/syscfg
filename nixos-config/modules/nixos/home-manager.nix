{ inputs, ... }:

{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager-stable.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
  };
}
