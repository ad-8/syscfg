{
  description = "foo";

  inputs = {
    nixpkgs-stable.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager-stable = { url = "github:nix-community/home-manager/release-26.05"; inputs.nixpkgs.follows = "nixpkgs-stable"; };
    # home-manager-unstable = { url = "github:nix-community/home-manager/master"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    mangowm = { url = "github:mangowm/mango/0.18.6"; inputs.nixpkgs.follows = "nixpkgs-stable"; };
    agenix = { url = "github:ryantm/agenix"; inputs.nixpkgs.follows = "nixpkgs-stable"; };
    # TODO: pinned to the last rev before fdd668c8 broke the nix build (libcava.wrap vs nix/default.nix);
    #       back to plain master once Alexays/Waybar#5427 is merged
    #       (moot if the input goes first, see the waybar overlay TODO in modules/desktop/mango.nix)
    waybar = { url = "github:alexays/waybar/c15ec02ede4343592a59eb5c2ff4443c9c045f7c"; inputs.nixpkgs.follows = "nixpkgs-stable"; };
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs-stable"; };
    # TODO: consider replacing with a ~10-line lib.fileset import (vimjoyer/nixconf flake.nix) once dendritic has proven itself;
    #       his filter only skips `_` file names, add a whole-path `/_` check
    import-tree.url = "github:denful/import-tree";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];
    };
}
