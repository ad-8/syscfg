{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-fuji = inputs.nixpkgs-stable.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = with modules.nixos; [
      base
      core
      btop
      fastfetch
      fish
      git
      openssh
      starship
      tmux
      vim
      ax-fuji
    ];
  };

  flake.modules.nixos.ax-fuji =
    { pkgs, ... }:
    {
      imports = [
        ./_hardware.nix
      ];

      boot.initrd.luks.devices."luks-2fc19056-a600-4e50-8de6-47b442b623c9".device =
        "/dev/disk/by-uuid/2fc19056-a600-4e50-8de6-47b442b623c9";

      networking.hostName = "ax-fuji";

      environment.systemPackages = with pkgs; [
        # services.jellyfin only installs pkgs.jellyfin; web and ffmpeg must be explicit
        jellyfin-ffmpeg
        jellyfin-web
        podman-compose
        rclone
        restic
        vlock
        yt-dlp
      ];

      users.users.ax = {
        packages = [ ];
        extraGroups = [
          "podman"
          "render"
        ];
        # start ax's user services at boot, without a login (for podman-restart)
        linger = true;
      };

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-compute-runtime-legacy1
        ];
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          2283 # immich
          3000 # forgejo
          3388 # TODOmacs
          5232 # radicale
          8888 # searxng
          9090 # linkding
        ];
        allowedUDPPorts = [ ];
      };

      system.stateVersion = "25.05";
    };
}
