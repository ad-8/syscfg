{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/laptop/default.nix
  ];

  boot.initrd.luks.devices."luks-8e763d50-8c69-4cf3-9f68-57652e1fede8".device = 
    "/dev/disk/by-uuid/8e763d50-8c69-4cf3-9f68-57652e1fede8";

  networking.hostName = "ax-t14";

  system.stateVersion = "25.11";
}
