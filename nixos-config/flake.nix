{
  description = "foo";

  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-26.05";
    # nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    # home-manager-unstable = {
    #   url = "github:nix-community/home-manager/master";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    hyprland.url = "github:hyprwm/Hyprland/v0.55.3";
  };

  outputs =
    {
      self,
      nixpkgs-stable,
      home-manager-stable,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      mkConfig =
        {
          hostname,
          username ? "ax",
          nixpkgs ? nixpkgs-stable,
          home-manager ? home-manager-stable,
        }:
        let
          hm =
            if home-manager != null then
              [
                home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.${username} = import ./hosts/${hostname}/home.nix;
                    backupFileExtension = "backup";
                  };
                }
              ]
            else
              [ ];
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; }; # makes inputs available to all modules, needed to reference inputs.hyprland directly
          modules = [
            ./hosts/${hostname}/configuration.nix
          ]
          ++ hm;
        };
    in
    {
      nixosConfigurations = {
        ax-bee = mkConfig { hostname = "ax-bee"; };
        ax-fuji = mkConfig {
          hostname = "ax-fuji";
          home-manager = null;
        };
        ax-mac = mkConfig { hostname = "ax-mac"; };
        ax-t14 = mkConfig { hostname = "ax-t14"; };
        ax-vm = mkConfig { hostname = "ax-vm"; };
      };
    };
}
