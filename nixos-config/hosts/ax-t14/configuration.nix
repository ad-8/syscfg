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

  system.stateVersion = "25.11";
}
