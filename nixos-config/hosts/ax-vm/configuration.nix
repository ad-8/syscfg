{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/vm/default.nix
  ];

  networking.hostName = "ax-vm";

  system.stateVersion = "25.11";
}
