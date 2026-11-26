{
  flake.modules.nixos.ax-fuji = {
    age.secrets.ax-fuji-restic-immich = {
      file = ../../../secrets/ax-fuji-restic-immich.age;
      owner = "ax";
    };

    age.secrets.ax-bee-restic-b2 = {
      file = ../../../secrets/ax-bee-restic-b2.age;
      owner = "ax";
    };

    services.cron = {
      enable = true;
      systemCronJobs = [
        # run backup scripts
        "10 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_radicale.clj >> $HOME/cron-radicale.log 2>&1; /usr/bin/env bb $HOME/x/backup/report.clj radicale $? >> $HOME/cron-radicale.log 2>&1"
        "12 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_linkding.clj >> $HOME/cron-linkding.log 2>&1; /usr/bin/env bb $HOME/x/backup/report.clj linkding $? >> $HOME/cron-linkding.log 2>&1"
        "15 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_immich.clj >> $HOME/cron-immich.log 2>&1; /usr/bin/env bb $HOME/x/backup/report.clj immich $? >> $HOME/cron-immich.log 2>&1"
        "25 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_rclone_b2.clj >> $HOME/cron-rclone-b2.log 2>&1; /usr/bin/env bb $HOME/x/backup/report.clj rclone-b2 $? >> $HOME/cron-rclone-b2.log 2>&1"
        # download daily wallpaper
        "0 9,10,11 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/bing_wallpaper_dl.clj >> $HOME/bing.log 2>&1"
      ];
    };
  };
}
