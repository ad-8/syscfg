{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-bee = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = with modules.nixos; [
      base
      core
      home-manager
      mango
      audio
      clamav
      distrobox
      firefox
      gaming
      keyd
      mu4e
      openssh
      printing
      restic
      syncthing
      virtman
      workstation
      zfs
      ax-bee
      {
        home-manager.users.ax.imports = [
          modules.homeManager.ax
          modules.homeManager.mango
          modules.homeManager.gaming
          modules.homeManager.mu4e
        ];
      }
    ];
  };

  flake.modules.nixos.ax-bee =
    {
      pkgs,
      config,
      ...
    }:

    {
      imports = [
        ./_hardware-configuration.nix
      ];

      # TODO: remove the emacs override once nixos stable ships emacs >= 31.1, likely with the 26.11 upgrade (fixes the save-place tramp error)
      nixpkgs.overlays = [
        (final: prev: {
          emacs = inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.emacs;
        })
      ];

      boot.initrd.luks.devices."luks-1101d87b-2380-4455-a516-1dda026f32e3".device =
        "/dev/disk/by-uuid/1101d87b-2380-4455-a516-1dda026f32e3";
      networking.hostName = "ax-bee";
      networking.networkmanager.wifi.powersave = false;

      # android adb setup
      # 26.05: programs.adb removed (systemd 258 handles uaccess rules
      # automatically); just install the tool and the adbusers group is gone
      environment.systemPackages = [ pkgs.android-tools ];

      networking.hostId = "315ecd42"; # generated via `head -c4 /dev/urandom | od -A none -t x4`

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "25.05"; # Did you read the comment?
    };
}
