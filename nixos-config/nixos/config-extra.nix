{
  config,
  lib,
  pkgs, inputs,
  ...
}:

{
  options = {
    configExtra.enable = lib.mkEnableOption "Enable extra config";
  };

  config = lib.mkIf config.configExtra.enable {
    networking.networkmanager.enable = true;

    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true; # load gnome-keyring at startup
    programs.seahorse.enable = true; # GUI to manage secrets

    # https://wiki.nixos.org/wiki/Backlight
    hardware.i2c.enable = true;
    # thanks https://mynixos.com/nixpkgs/option/programs.light.enable
    programs.light.enable = true;

    services = {
      syncthing = {
        enable = true;
        openDefaultPorts = true;
        group = "users";
        user = "ax";
        dataDir = "/home/ax/syncthing"; # Default folder for new synced folders
        configDir = "/home/ax/.config/syncthing"; # Folder for Syncthing's settings and keys
      };
    };


    # use cachix to avoid building hyprland locally
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    # TODO put settings in the following sections in config-<category>.nix files
    # -------------------------------------
    services.xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 35;
    };
    services.displayManager.ly.enable = true;
    # systemd.services.display-manager.enable = false; # disables all display managers. NixOS defaults to LightDM when no display-manager is explicitly enabled
    programs.hyprland = {
      enable = true;

      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      withUWSM = false;
      xwayland.enable = true;
    };


    # -------------------------------------
    programs.firefox.enable = true;
    programs.java.enable = true;
    # https://wiki.nixos.org/wiki/Thunar
    programs.thunar.enable = true;
    programs.xfconf.enable = true;
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
    # -------------------------------------
    fonts.packages = with pkgs; [
      nerd-fonts.hack
    ];
    # -------------------------------------

    hardware.bluetooth.enable = true;
    services.blueman.enable = true; # provides blueman-applet and blueman-manager

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      ffmpeg-full
      restic
      rclone
      libsecret
      xwayland-satellite # xwayland support for niri
    ];

    # The firewall is enabled by default on NixOS. Still, explicitly ensure it is enabled
    networking.firewall.enable = true;
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
  };
}
