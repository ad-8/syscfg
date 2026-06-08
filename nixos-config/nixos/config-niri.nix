{
  config,
  lib,
  pkgs,
  ...
}:

# Opt-in niri scrolling-tiling Wayland session, from stable nixpkgs.
# Default-off; flip configNiri.enable on a host (mutually exclusive with the
# Hyprland session - both define a Wayland session). Launches from tty1 like
# Hyprland, no display manager. Portals are handled by the programs.niri module
# (xdg-desktop-portal-gnome + niri-specific routing) - do not re-declare them.

{
  options = {
    configNiri.enable = lib.mkEnableOption "Enable the niri Wayland session";
  };

  config = lib.mkIf config.configNiri.enable {
    programs.niri.enable = true;

    # The niri module builds with enableXWayland = false; xwayland-satellite
    # provides X11 app support (not auto-spawned - start it from niri autostart).
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
