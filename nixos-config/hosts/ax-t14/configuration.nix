{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/laptop/base.nix
  ];

  # boot.initrd.luks.devices = TODO

  networking.hostName = "ax-t14";

  system.stateVersion = "25.11";
}
