{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configNiri.enable = lib.mkEnableOption "Enable the niri Wayland session";
  };

  config = lib.mkIf config.configNiri.enable {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      gammastep
      kitty # kitten quick-access-terminal as scratchpad replacement
      swayidle
      xwayland-satellite
    ];
  };
}
