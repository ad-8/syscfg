{
  flake.modules.nixos.gatus-push =
    { config, pkgs, ... }:
    {
      systemd.timers.gatus-push = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "1m";
          OnUnitActiveSec = "60s";
          Unit = "gatus-push.service";
        };
      };

      systemd.services.gatus-push = {
        description = "Push service health to the Gatus status page";
        serviceConfig = {
          Type = "oneshot";
          User = "ax";
          ExecStart = "${pkgs.babashka}/bin/bb ${config.users.users.ax.home}/x/srv/gatus_push.clj";
        };
      };
    };
}
