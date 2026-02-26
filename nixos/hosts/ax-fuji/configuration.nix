{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/configuration-core.nix
    ./homepage-dashboard.nix
  ];

  boot.initrd.luks.devices."luks-2fc19056-a600-4e50-8de6-47b442b623c9".device =
    "/dev/disk/by-uuid/2fc19056-a600-4e50-8de6-47b442b623c9";
  boot.supportedFilesystems = [ "nfs" ]; # installs NFS utilities for the client
  networking.hostName = "ax-fuji";

  environment.systemPackages = with pkgs; [
    emacs
    vlock

    # cli tools
    delta
    eza
    fastfetch
    fd
    fzf
    gh
    htop
    nnn
    ripgrep
    starship
    stow
    tokei
    zoxide

    # backup
    restic
    rclone

    # code
    babashka
    ruby_3_4

    # selfhosting
    podman-compose
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  # TODO why bother with separating pkgs?
  users.users.ax = {
    packages = [];
  };

  networking.firewall.enable = true; # enabled by default, still enable explicitly
  networking.firewall.allowedTCPPorts = [
    2283
    5232
    9090
  ]; # immich, radicale, linkding
  # networking.firewall.allowedUDPPorts = [ ... ];

  services = {
    cron = {
      enable = true;
      systemCronJobs = [
        "10 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_radicale.clj >> ~/cron-radicale.log 2>&1"
        "12 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_linkding.clj >> ~/cron-linkding.log 2>&1"
        "15 3 * * *     ax     . /etc/profile; ruby $HOME/x/backup/ax-srv-backup-immich.rb >> ~/cron-immich.log 2>&1"
        "25 3 * * *     ax     . /etc/profile; /usr/bin/env bb $HOME/x/backup/ax_srv_rclone_b2.clj >> ~/cron-rclone-b2.log 2>&1"
        # download daily wallpaper
        "0 9,10,11 * * *     ax     . /etc/profile; nix develop ~/x --command ruby ~/x/bing_wallpaper_dl.rb >> ~/bing.log 2>&1"
      ];
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
      user = "ax";
    };
    openssh = {
      enable = true;
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
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
