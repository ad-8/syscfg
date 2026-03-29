{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/config-core.nix
    ./homepage-dashboard.nix
  ];

  boot.initrd.luks.devices."luks-2fc19056-a600-4e50-8de6-47b442b623c9".device = "/dev/disk/by-uuid/2fc19056-a600-4e50-8de6-47b442b623c9";

  networking.hostName = "ax-fuji";

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-ffmpeg
    jellyfin-web
    podman-compose
    rclone
    restic
    ruby_3_4
    vlock
  ];

  users.users.ax = {
    packages = [];
    extraGroups = [ "podman" ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      2283 # immich
      3000 # forgejo
      5232 # radicale
      9090 # linkding
    ];
    allowedUDPPorts = [ ];
  };

  services = {
    cron = {
      enable = true;
      systemCronJobs = [
        # run backup scripts
        "10 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_radicale.clj >> ~/cron-radicale.log 2>&1"
        "12 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_linkding.clj >> ~/cron-linkding.log 2>&1"
        "15 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_immich.clj >> ~/cron-immich.log 2>&1"
        "25 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_rclone_b2.clj >> ~/cron-rclone-b2.log 2>&1"
        # download daily wallpaper
        "0 9,10,11 * * *     ax     . /etc/profile; nix develop ~/x --command ruby ~/x/bing_wallpaper_dl.rb >> ~/bing.log 2>&1"
      ];
    };
    forgejo = {
      enable = true;
      settings = {
        server = {
          # after setting this, the repo URLs in the GUI contain this $DOMAIN instead of localhost
          DOMAIN = "192.168.178.8";
          # fixes warning: "This Forgejo instance is configured to be served on "http://localhost:3000/".
          # You are currently viewing Forgejo through a different URL, which may cause parts of the application to break.
          # The canonical URL is controlled by Forgejo admins via the ROOT_URL setting in the app.ini."
          ROOT_URL = "http://192.168.178.8:3000"; 
        };
      };
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
      user = "ax";
    };
    openssh = {
      enable = true;
      # ports = [ 5432 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        # AllowUsers = [ "myUser" ];
      };
    };
    radicale = {
      enable = true;
      settings = {
        server.hosts = [ "0.0.0.0:5232" ];
        auth = {
          type = "htpasswd";
          htpasswd_filename = "/var/lib/radicale/radicale_users";
          htpasswd_encryption = "bcrypt";
        };
      };
    };
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      group = "users";
      user = "ax";
      dataDir = "/home/ax/syncthing"; # Default folder for new synced folders
      configDir = "/home/ax/.config/syncthing"; # Folder for Syncthing's settings and keys
    };
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # Create an alias mapping docker to podman.
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  # -----------------------------------------------------------------------------------------------
  systemd.timers.forgejo-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:17:00";
      Unit = "forgejo-backup.service";
    };
  };

  systemd.services.forgejo-backup = {
    description = "Forgejo Backup Service";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      babashka
      gnutar
      gzip
      util-linux # required for mountpoint
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${pkgs.babashka}/bin/bb /home/ax/x/backup/ax_srv_forgejo.clj";
      RemainAfterExit = false; # TODO see if this does NOT trigger a backup when running `nixos-rebuild`
    };
  };
  # -----------------------------------------------------------------------------------------------

  system.stateVersion = "25.05";
}
