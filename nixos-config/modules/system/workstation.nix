{
  flake.modules.nixos.workstation =
    { pkgs, ... }:
    {
      networking.networkmanager.enable = true;

      # https://wiki.nixos.org/wiki/WireGuard#wg-quick_issues_with_NetworkManager
      # didn't have this problem, but for me,
      # prevents DNS leaks and works well with `wg-quick up`
      networking.networkmanager.dns = "systemd-resolved";
      services.resolved.enable = true;

      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true;
      # seahorse is a GUI to manage secrets.
      # Make sure make 'Login' the default keyring, so it gets unlocked automatically
      # (now works from the TTY, no display manager).
      # 'Default keyring' was set as default before, and after reboot, the keyring had to be manually unlocked ...
      # Also, apparently, the passwd for the 'Login' keyring and the user passwd should match.
      programs.seahorse.enable = true;

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
        libsecret
      ];

      programs.direnv.enable = true;

      # The firewall is enabled by default on NixOS. Still, explicitly ensure it is enabled
      networking.firewall.enable = true;
      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
    };
}
