{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configWorkstation.enable = lib.mkEnableOption "Enable the desktop/GUI support layer (networking, bluetooth, keyring, fonts, file manager) above the minimal core";
  };

  config = lib.mkIf config.configWorkstation.enable {
    networking.networkmanager.enable = true;

    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
    # seahorse is a GUI to manage secrets.
    # Make sure make 'Login' the default keyring, so it gets unlocked automatically
    # (now works via `start-hyprland` from TTY, no display manager).
    # 'Default keyring' was set as default before, and after reboot, the keyring had to be manually unlocked ...
    # Also, apparently, the passwd for the 'Login' keyring and the user passwd should match.
    programs.seahorse.enable = true;

    # https://wiki.nixos.org/wiki/Backlight
    hardware.i2c.enable = true;
    # brillo replaces light (removed from nixpkgs in 26.05, unmaintained upstream);
    # same udev + video-group model, no setuid. licht.clj calls `brillo` now.
    hardware.brillo.enable = true;

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

    environment.systemPackages = with pkgs; [
      ffmpeg-full
      restic
      rclone
      libsecret
    ];

    # The firewall is enabled by default on NixOS. Still, explicitly ensure it is enabled
    networking.firewall.enable = true;
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
  };
}
