{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/laptop/base.nix
  ];

  boot.initrd.luks.devices."luks-61a74d46-4933-489e-b52b-e52eb084e55b".device = "/dev/disk/by-uuid/61a74d46-4933-489e-b52b-e52eb084e55b";


  networking.hostName = "ax-t14";

  # setup from https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "18289c90"; # generated via `head -c4 /dev/urandom | od -A none -t x4`

  system.stateVersion = "25.11";
}
