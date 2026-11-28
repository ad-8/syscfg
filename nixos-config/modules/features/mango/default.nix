{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.modules.nixos.mango =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [
        inputs.mangowm.nixosModules.mango
        modules.nixos.home-manager
      ];

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

          # https://wiki.nixos.org/wiki/Backlight
          hardware.i2c.enable = true;
          users.users.ax.extraGroups = [
            config.hardware.i2c.group
          ];
          # brillo replaces light (removed from nixpkgs in 26.05, unmaintained upstream);
          # same udev + video-group model, no setuid. licht.clj calls `brillo` now.
          hardware.brillo.enable = true;

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
      ];
    };

  flake.modules.homeManager.mango =
    { pkgs, ... }:
    {
      xdg.configFile = {
        "mango/config.conf".source = ../../desktop/mango/config.conf;

        "waybar/compositor-mango.json".source = ../../desktop/waybar/compositor-mango.json;
        "waybar/config".source = ../../desktop/waybar/config;
        "waybar/config-minimal".source = ../../desktop/waybar/config-minimal;
        "waybar/snowflake.xml".source = ../../desktop/waybar/snowflake.xml;
        "waybar/style.css".source = ../../desktop/waybar/style.css;

        "dunst/dunstrc".source = ../../desktop/dunst/dunstrc;

        "rofi/config.rasi".source = ../../desktop/rofi/config.rasi;
        "rofi/picker.rasi".source = ../../desktop/rofi/picker.rasi;
      };

      home.packages = with pkgs; [
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
