{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  options = {
    configMango.enable = lib.mkEnableOption "Enable the mango Wayland session";
  };

  config = lib.mkIf config.configMango.enable (
    lib.mkMerge [
      {
        programs.mango.enable = true;

        environment.systemPackages = with pkgs; [
          gammastep
          swayidle
          wlopm
          wlr-randr
        ];
      }

      (import (modulesPath + "/programs/wayland/wayland-session.nix") {
        inherit lib pkgs;
        enableWlrPortal = true;
      })
    ]
  );
}
