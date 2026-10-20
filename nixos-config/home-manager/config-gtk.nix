{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    configGtk.enable = lib.mkEnableOption "Enable GTK config";
  };

  config = lib.mkIf config.configGtk.enable {
    # creates ~/.icons/default/index.theme (Inherits=Numix-Cursor), the catch-all for
    # apps whose cursor lookup falls back to the "default" theme -- XWayland apps under
    # xwayland-satellite don't learn the theme name from niri's XCURSOR_THEME env var
    # (xwayland-satellite issue #421); also sets XCURSOR_THEME/XCURSOR_SIZE session vars
    home.pointerCursor = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
      size = 24;
    };

    # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
    gtk = {
      enable = true;
      colorScheme = "dark";
      # works -> see e.g. nm-applet tray icon
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      # works -> set in sway config and .Xresources (for xwayland)
      cursorTheme = {
        name = "Numix-Cursor";
        package = pkgs.numix-cursor-theme;
      };
    };

    dconf.settings."org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita";
      accent-color = "orange";
    };
  };
}
