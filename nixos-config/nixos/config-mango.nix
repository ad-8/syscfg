{
  config,
  lib,
  pkgs,
  inputs,
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

        # replace stable waybar with master (pinned rev, see the waybar input in flake.nix) via overlay
        # TODO: remove (plus the waybar flake input) once nixos stable ships a waybar release with the mango/* modules (> 0.15.0), likely with the 26.11 upgrade
        nixpkgs.overlays = [
          (final: prev: {
            waybar = inputs.waybar.packages.${prev.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
              doCheck = false;
              mesonFlags = map (f: if f == "-Dtests=enabled" then "-Dtests=disabled" else f) old.mesonFlags;
            });
          })
        ];

        xdg.portal.wlr.settings.screencast = {
          chooser_type = "dmenu";
          chooser_cmd = "${lib.getExe pkgs.rofi} -dmenu -p share";
        };

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
