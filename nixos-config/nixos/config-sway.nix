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

    environment.systemPackages = with pkgs; [
      gammastep
    ];
  };
}
