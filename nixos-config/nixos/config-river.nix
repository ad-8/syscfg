{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  options = {
    configRiver.enable = lib.mkEnableOption "Enable the river Wayland session";
  };

  config = lib.mkIf config.configRiver.enable (
    lib.mkMerge [
      {
        # river 0.4 has no NixOS module in nixpkgs: `programs.river` was renamed
        # `programs.river-classic`, which still installs the monolithic 0.3.x
        # package. river ships its own session desktop file, so registering it
        # is all that module would have done for us.
        services.displayManager.sessionPackages = [ pkgs.river ];

        # the key has to match XDG_CURRENT_DESKTOP, which river/init exports.
        # neither wlr nor gtk implements the Secret interface, so it needs
        # naming explicitly.
        xdg.portal.config.river = {
          default = [
            "wlr"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };

        environment.systemPackages = with pkgs; [
          kitty # use kitten thing as scratchpad replacement
          river
          gammastep
          swayidle
          wlopm # per-output dpms
          wlr-randr # mode/position/scale
        ];
      }

      # the same file the niri, hyprland and sway modules pull in: polkit,
      # swaylock's pam entry, dconf, xwayland, default fonts, xdg-utils,
      # the gtk portal and xdg autostart
      (import (modulesPath + "/programs/wayland/wayland-session.nix") {
        inherit lib pkgs;
        enableWlrPortal = true; # river is wlroots; niri and hyprland set false
      })
    ]
  );
}
