let
  serverIp = "192.168.178.8";
in
{
  flake.modules.nixos.forgejo =
    { config, pkgs, ... }:
    {
      networking.firewall.allowedTCPPorts = [ 3000 ];

      services.forgejo = {
        enable = true;
        settings = {
          server = {
            # after setting this, the repo URLs in the GUI contain this $DOMAIN instead of localhost
            DOMAIN = serverIp;
            # fixes warning: "This Forgejo instance is configured to be served on "http://localhost:3000/".
            # You are currently viewing Forgejo through a different URL, which may cause parts of the application to break.
            # The canonical URL is controlled by Forgejo admins via the ROOT_URL setting in the app.ini."
            ROOT_URL = "http://${serverIp}:3000";
          };
        };
      };

      systemd.timers.forgejo-backup = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "03:17:00";
          Unit = "forgejo-backup.service";
        };
      };

      systemd.services.forgejo-backup = {
        description = "Forgejo Backup Service";
        path = with pkgs; [
          babashka
          gnutar
          gzip
          util-linux # required for `mountpoint` cmd
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart = "${pkgs.babashka}/bin/bb ${config.users.users.ax.home}/x/backup/ax_srv_forgejo.clj";
          # "-": a failed report must not mark the backup as failed
          ExecStopPost = "-${pkgs.babashka}/bin/bb ${config.users.users.ax.home}/x/backup/report.clj forgejo";
        };
      };
    };
}
