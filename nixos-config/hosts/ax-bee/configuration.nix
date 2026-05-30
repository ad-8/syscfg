{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./restic.nix
    ../../nixos/config-core.nix
    ../../nixos/all-modules.nix
  ];

  configExtra.enable = true;
  configFirefox.enable = true;
  configHyprland.enable = true;
  configClamav.enable = true;
  configGaming.enable = true;
  configPrinting.enable = true;
  configVirtman.enable = true;
  configDistrobox.enable = true;

  boot.initrd.luks.devices."luks-1101d87b-2380-4455-a516-1dda026f32e3".device =
    "/dev/disk/by-uuid/1101d87b-2380-4455-a516-1dda026f32e3";
  networking.hostName = "ax-bee";

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.capslock = "overload(control, esc)";
    };
  };

  # https://wiki.nixos.org/wiki/WireGuard#wg-quick_issues_with_NetworkManager
  # didn't have this problem, but for me,
  # prevents DNS leaks and works well with `wg-quick up`
  # TODO for all machines?
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  # android adb setup
  programs.adb.enable = true;

  users.users.ax.extraGroups = [
    "adbusers"
    "i2c"
  ];

  services.openssh = {
    enable = true;
    # ports = [ 5432 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      # AllowUsers = [ "myUser" ];
    };
  };

  # setup from https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "315ecd42"; # generated via `head -c4 /dev/urandom | od -A none -t x4`

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
