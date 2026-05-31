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
    # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
    gtk = {
      enable = true;
      # works -> see e.g. thunar
      theme = {
        # name = "Arc-Dark";
        # package = pkgs.arc-theme;
        # name = "Dracula";
        # package = pkgs.dracula-theme;
        name = "Nordic"; # or Nordic-darker
        package = pkgs.nordic;
        # name = "Yaru-dark";
        # package = pkgs.yaru-theme;
      };
      # 26.05 changed gtk4.theme's default from config.gtk.theme to null;
      # keep GTK4 apps on the same theme as GTK3
      gtk4.theme = config.gtk.theme;
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
  };
}
