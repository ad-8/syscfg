{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/laptop/default.nix
  ];

  boot.initrd.luks.devices."luks-f43e8971-1fb7-4d8c-be86-c8162a78d104".device =
    "/dev/disk/by-uuid/f43e8971-1fb7-4d8c-be86-c8162a78d104";

  networking.hostName = "ax-t14";

  system.stateVersion = "25.11";
}
