{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/configuration-core.nix
    ../../nixos/ax-configs.nix
  ];

  configExtra.enable = true;
  configClamav.enable = true;
  configPrinting.enable = true;
  configVirtman.enable = true;

  boot.initrd.luks.devices."luks-1101d87b-2380-4455-a516-1dda026f32e3".device =
    "/dev/disk/by-uuid/1101d87b-2380-4455-a516-1dda026f32e3";
  networking.hostName = "ax-bee";

  services.keyd = {
    enable = true;
    keyboards = {
      # The name is just the name of the configuration file, it does not really matter
      default = {
        ids = [ "*" ]; # what goes into the [id] section, here we select all keyboards
        # Everything but the ID section:
        settings = {
          # The main layer, if you choose to declare it in Nix
          main = {
            # Maps capslock to escape when pressed and control when held.
            capslock = "overload(control, esc)";
            # leftalt = "leftmeta";
            # leftmeta = "leftalt";
          };
          otherlayer = { };
        };
        extraConfig = ''
          # put here any extra-config, e.g. you can copy/paste here directly a configuration, just remove the ids part
        '';
      };
    };
  };

  # -----------------------------------------------------------------------------------------------
  # TODO this could be one line in the systemCronJobs vector below ...
  systemd.timers."ax-restic" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # OnCalendar="*:0/1"; # every minute
      # OnCalendar = "*-*-* *:01:00";  # every hour at minute 1, second 0
      OnCalendar = "*-*-* *:00/30:00"; # every 30 minutes
      Unit = "ax-restic.service";
    };
  };

  systemd.services."ax-restic" = {
    description = "Restic backup service";
    wantedBy = [ "multi-user.target" ];
    # the $PATH is almost empty when running a systemd service, so we add to it
    path = [
      pkgs.restic
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "ax";
      ExecStart = "${pkgs.babashka}/bin/bb /home/ax/x/backup/ax_bee_restic_mega.clj";
      RemainAfterExit = false; # see nixos wiki
    };
  };
  # -----------------------------------------------------------------------------------------------

  services.cron = {
    enable = true;
    systemCronJobs = [
      "5 */2 * * *     ax     . /etc/profile; ruby $HOME/x/backup/ax_bee_restic_b2.rb >> ~/restic.log 2>&1"
    ];
  };

  programs.steam.enable = true;
  # heroic wiki recommends
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  # https://wiki.nixos.org/wiki/WireGuard#wg-quick_issues_with_NetworkManager
  # didn't have this problem, but for me,
  # prevents DNS leaks and works well with `wg-quick up`
  # TODO for all machines?
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  # -----------------------------------------------------------------------------------------------
  # distrobox
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  environment.systemPackages = with pkgs; [
    distrobox
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
        pkgs.mangohud
      ];
    })
  ];
  # -----------------------------------------------------------------------------------------------

  # android adb setup
  programs.adb.enable = true;
  users.users.ax.extraGroups = [ "adbusers" ];

  # LocalSend
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
