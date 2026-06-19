{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  options = {
    configHyprland.enable = lib.mkEnableOption "Enable the Hyprland Wayland session";
  };

  config = lib.mkIf config.configHyprland.enable {
    # use cachix to avoid building hyprland locally
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    programs.hyprland = {
      enable = true;

      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      withUWSM = false;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      hypridle
      hyprsunset
    ];
  };
}
