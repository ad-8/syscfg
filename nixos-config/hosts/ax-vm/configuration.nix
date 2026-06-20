{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/vm/base.nix
  ];

  networking.hostName = "ax-vm";

  services.openssh.enable = true;

  system.stateVersion = "25.11";
}
