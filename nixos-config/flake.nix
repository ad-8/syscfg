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
    hyprland.url = "github:hyprwm/Hyprland/v0.56.1";
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.darwin.follows = "";
    };
    waybar = {
      url = "github:alexays/waybar";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    {
      self,
      nixpkgs-stable,
      home-manager-stable,
      waybar,
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
            inputs.agenix.nixosModules.default
            inputs.mangowm.nixosModules.mango

            # replace stable waybar with latest master via overlay
             ({ pkgs, ... }: {
              nixpkgs.overlays = [
                (final: prev: {
                  waybar = waybar.packages.${system}.default;
                })
              ];
            })
            
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
