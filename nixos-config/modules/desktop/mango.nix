{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.modules.nixos.mango =
    {
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [ modules.nixos.home-manager ];

      config = lib.mkMerge [
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

          home-manager.sharedModules = [ modules.homeManager.mango ];
        }

        (import (modulesPath + "/programs/wayland/wayland-session.nix") {
          inherit lib pkgs;
          enableWlrPortal = true;
        })
      ];
    };

  flake.modules.homeManager.mango =
    { pkgs, ... }:
    {
      xdg.configFile = {
        "mango/config.conf".source = ./mango/config.conf;

        "waybar/compositor-mango.json".source = ./waybar/compositor-mango.json;
        "waybar/config".source = ./waybar/config;
        "waybar/config-minimal".source = ./waybar/config-minimal;
        "waybar/snowflake.xml".source = ./waybar/snowflake.xml;
        "waybar/style.css".source = ./waybar/style.css;

        "dunst/dunstrc".source = ./dunst/dunstrc;

        "rofi/config.rasi".source = ./rofi/config.rasi;
        "rofi/picker.rasi".source = ./rofi/picker.rasi;
      };

      home.packages = with pkgs; [
        # brillo enabled in modules/system/workstation.nix
        bluetui
        ddcutil
        dunst
        grim
        libnotify
        networkmanagerapplet
        playerctl
        rofi
        slurp
        swaybg
        swaylock
        waybar
        wiremix
        wl-clipboard
        wlr-which-key
      ];
    };
}
