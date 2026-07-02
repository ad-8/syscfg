{
  pkgs, config,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./restic.nix
    ../../nixos/config-core.nix
    ../../nixos/all-modules.nix
  ];

  configWorkstation.enable = true;
  configFirefox.enable = true;
  configNiri.enable = true;
  configAudio.enable = true;
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

  # android adb setup
  # 26.05: programs.adb removed (systemd 258 handles uaccess rules
  # automatically); just install the tool and the adbusers group is gone
  environment.systemPackages = [ pkgs.android-tools ];

  users.users.ax.extraGroups = [
    "i2c"
  ];

  # TODO remove once more familiar with agenix
  age.secrets.testuser-password.file = ../../secrets/testuser-password.age;
  users.users.testuser = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.testuser-password.path;
  };

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
