{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-fuji = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = with modules.nixos; [
      # foundation
      agenix
      core

      # services
      audiobookshelf
      forgejo
      gatus-push
      homepage
      jellyfin
      navidrome
      radicale
      searx
      syncthing

      # system
      openssh
      podman

      # apps
      doom-link

      # cli
      btop
      fastfetch
      fish
      git
      restic
      starship
      tmux
      vim

      # host
      ax-fuji
    ];
  };

  flake.modules.nixos.ax-fuji =
    { pkgs, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
      ];

      boot.initrd.luks.devices."luks-2fc19056-a600-4e50-8de6-47b442b623c9".device =
        "/dev/disk/by-uuid/2fc19056-a600-4e50-8de6-47b442b623c9";

      networking.hostName = "ax-fuji";

      environment.systemPackages = with pkgs; [
        vlock
        yt-dlp
      ];

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
          3388 # TODOmacs
          9090 # linkding
        ];
        allowedUDPPorts = [ ];
      };

      system.stateVersion = "25.05";
    };
}
