{
  config,
  lib,
  pkgs,
  ...
}:

# Opt-in X11 + XFCE + LightDM fallback, kept for games that don't run on Wayland.
# NOTE: enabling this reinstates a display manager and graphical.target, which pauses
# the tty1-launch Hyprland workflow (Hyprland is still selectable at the LightDM
# greeter). Default-off; the clean Wayland + tty1 setup is the normal state.

{
  options = {
    configXorg.enable = lib.mkEnableOption "Enable the opt-in X11/XFCE (LightDM) fallback session";
  };

  config = lib.mkIf config.configXorg.enable {
    services.xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 35;
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
    };
    # services.displayManager.ly.enable = true;
    # No display-manager is set explicitly: NixOS then defaults to LightDM, which is
    # exactly what we want here. (On the Wayland path config-extra used to force this
    # off via `systemd.services.display-manager.enable = false`; that hack is gone now
    # that X is opt-in.)
    # LightDM auto-enables; pick XFCE or Hyprland at the greeter.
    services.displayManager.defaultSession = "xfce";
  };
}
