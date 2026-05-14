{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    pkgsWm.enable = lib.mkEnableOption "Enable WM pkgs";
  };

  config = lib.mkIf config.pkgsWm.enable {
    home.packages = with pkgs; [
      # light # enabled in configuration.nix
      bluetui
      ddcutil
      dunst
      fuzzel
      grim
      hypridle
      hyprsunset
      libnotify
      networkmanagerapplet
      playerctl
      rofi
      slurp
      swappy
      swaybg
      swaylock
      waybar
      wiremix
      wl-clipboard
      wlr-which-key
      wmenu
    ];
  };
}
