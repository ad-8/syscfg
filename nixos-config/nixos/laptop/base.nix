{
  ...
}:

{
  imports = [
    ../config-core.nix
    ../all-modules.nix
  ];

  configExtra.enable = true;
  configFirefox.enable = true;
  configPrinting.enable = true;

  # ignore short presses of the power button entirely. Long-pressing your power button (5 seconds or longer)
  # to do a hard reset is handled by your machine’s BIOS/EFI and thus still possible.
  # (https://wiki.nixos.org/wiki/Systemd/logind)
  services.logind.settings.Login.HandlePowerKey = "ignore"; # started working after a reboot

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.capslock = "overload(control, esc)";
    };
  };

  # laptop battery info via `upower --dump`
  services.upower.enable = true;
}
