{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/config-core.nix
    ../../nixos/all-modules.nix
  ];

  configExtra.enable = true;
  configClamav.enable = true;
  configGaming.enable = true;
  configPrinting.enable = true;
  configVirtman.enable = true;
  configDistrobox.enable = true;

  boot.initrd.luks.devices."luks-1101d87b-2380-4455-a516-1dda026f32e3".device =
    "/dev/disk/by-uuid/1101d87b-2380-4455-a516-1dda026f32e3";
  networking.hostName = "ax-bee";

  # -----------------------------------------------------------------------------------------------
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
    # the $PATH is almost empty when running a systemd service, so we add to it
    path = [
      pkgs.restic
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "ax";
      ExecStart = "${pkgs.babashka}/bin/bb ${config.users.users.ax.home}/x/backup/ax_bee_restic_mega.clj";
    };
  };
  # -----------------------------------------------------------------------------------------------

  services.cron = {
    enable = true;
    systemCronJobs = [
      "5 */2 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_bee_restic_b2.clj >> $HOME/restic.log 2>&1"
    ];
  };

  # https://wiki.nixos.org/wiki/WireGuard#wg-quick_issues_with_NetworkManager
  # didn't have this problem, but for me,
  # prevents DNS leaks and works well with `wg-quick up`
  # TODO for all machines?
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  # android adb setup
  programs.adb.enable = true;

  # VM testing only — build: nixos-rebuild build-vm --flake .#ax-bee
  #                   launch: ./result/bin/run-ax-bee-vm
  users.users.ax.initialPassword = "test";

  users.users.ax.extraGroups = [
    "adbusers"
    "i2c"
  ];

  services.openssh = {
    enable = true;
    # ports = [ 5432 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      # AllowUsers = [ "myUser" ];
    };
  };

  # setup from https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "315ecd42"; # generated via `head -c4 /dev/urandom | od -A none -t x4`

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
