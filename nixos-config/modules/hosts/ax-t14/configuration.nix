{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-t14 = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = with modules.nixos; [
      # foundation
      core
      home-manager

      # role
      audio
      mango
      workstation

      # services
      syncthing

      # system
      keyd
      zfs

      # apps
      firefox

      # cli
      restic

      # host
      ax-t14
      {
        home-manager.users.ax.imports = with modules.homeManager; [
          workstation
          mango
        ];
      }
    ];
  };

  flake.modules.nixos.ax-t14 = {
    imports = [
      ./_hardware-configuration.nix
    ];

    # ignore short presses of the power button entirely. Long-pressing your power button (5 seconds or longer)
    # to do a hard reset is handled by your machine’s BIOS/EFI and thus still possible.
    # (https://wiki.nixos.org/wiki/Systemd/logind)
    services.logind.settings.Login.HandlePowerKey = "ignore"; # started working after a reboot

    # laptop battery info via `upower --dump`
    services.upower.enable = true;

    boot.initrd.luks.devices."luks-61a74d46-4933-489e-b52b-e52eb084e55b".device =
      "/dev/disk/by-uuid/61a74d46-4933-489e-b52b-e52eb084e55b";

    networking.hostName = "ax-t14";

    networking.hostId = "18289c90"; # generated via `head -c4 /dev/urandom | od -A none -t x4`

    system.stateVersion = "25.11";
  };
}
