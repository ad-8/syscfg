{ config, pkgs, ... }:

{
  systemd.timers."ax-restic-b2" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 00/2:05:00"; # every 2 hours at minute 5
      Unit = "ax-restic-b2.service";
    };
  };

  age.secrets.ax-bee-restic-b2 = {
    file = ../../secrets/ax-bee-restic-b2.age;
    owner = "ax";
  };

  systemd.services."ax-restic-b2" = {
    description = "Restic B2 backup service";
    path = [
      pkgs.restic
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "ax";
      EnvironmentFile = config.age.secrets.ax-bee-restic-b2.path;
      ExecStart = "${pkgs.babashka}/bin/bb ${config.users.users.ax.home}/x/backup/ax_bee_restic_b2.clj";
    };
  };

  systemd.timers."ax-restic" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # OnCalendar="*:0/1"; # every minute
      # OnCalendar = "*-*-* *:01:00";  # every hour at minute 1, second 0
      OnCalendar = "*-*-* *:00/30:00"; # every 30 minutes
      Unit = "ax-restic.service";
    };
  };

  age.secrets.ax-bee-restic-mega = {
    file = ../../secrets/ax-bee-restic-mega.age;
    owner = "ax";
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
      Environment = "RESTIC_PASSWORD_FILE=${config.age.secrets.ax-bee-restic-mega.path}";
      ExecStart = "${pkgs.babashka}/bin/bb ${config.users.users.ax.home}/x/backup/ax_bee_restic_mega.clj";
    };
  };
}
