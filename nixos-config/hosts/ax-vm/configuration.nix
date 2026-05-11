{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/vm/base.nix
  ];

  networking.hostName = "ax-vm";

  system.stateVersion = "25.11";
}
