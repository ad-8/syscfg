{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/laptop/base.nix
  ];

  boot.initrd.luks.devices."luks-f43e8971-1fb7-4d8c-be86-c8162a78d104".device =
    "/dev/disk/by-uuid/f43e8971-1fb7-4d8c-be86-c8162a78d104";

  networking.hostName = "ax-mac";

  # PC layout on the built-in keyboard: swap left alt/cmd and fn/left ctrl (right side and AltGr untouched)
  boot.extraModprobeConfig = "options hid_apple swap_opt_cmd=2 swap_fn_leftctrl=1";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
