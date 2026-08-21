{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configSway.enable = lib.mkEnableOption "Enable the sway Wayland session";
  };

  config = lib.mkIf config.configSway.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      # upstream default also pulls brightnessctl + pulseaudio (we use brillo +
      # wiremix) and foot/grim/swaylock/wmenu (already in pkgs-core / pkgs-wm)
      extraPackages = with pkgs; [ swayidle ];
    };

    # sway's module defines xdg.portal.config.sway with default = [ "gtk" ] and
    # never names Secret; gtk has no Secret backend, and an explicit default
    # suppresses the fallback search. niri's module names it and also pulls in
    # the gnome portal -- match that, since we enable gnome-keyring ourselves.
    xdg.portal = {
      config.sway."org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

    environment.systemPackages = with pkgs; [
      gammastep
    ];
  };
}
