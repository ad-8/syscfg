{ config, inputs, ... }:

{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager-stable.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.ax.imports = [ config.flake.modules.homeManager.home-manager ];
    };
  };

  flake.modules.homeManager.home-manager = {
    home.stateVersion = "25.05";
    home.username = "ax";
    home.homeDirectory = "/home/ax";

    programs.bash = {
      enable = true;
      shellAliases = {
        btw = "echo 'home-manager seems to be working :)'";
      };
    };
  };
}
