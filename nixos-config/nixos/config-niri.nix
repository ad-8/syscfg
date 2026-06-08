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

    # niri builds with enableXWayland = false; install xwayland-satellite (>= 0.7)
    # so niri's built-in integration (since niri 25.08) spawns it on-demand and
    # exports $DISPLAY for X11 clients - only needs the binary on PATH, no
    # spawn-at-startup. Both version thresholds are met by nixpkgs 26.05.
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
