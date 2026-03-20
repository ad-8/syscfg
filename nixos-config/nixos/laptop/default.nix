{
  ...
}:

{
  imports = [
    ../config-core.nix
    ../ax-configs.nix
  ];

  configExtra.enable = true;
  configClamav.enable = false;
  configPrinting.enable = true;
  configVirtman.enable = false;
  configDistrobox.enable = false;

  # ignore short presses of the power button entirely. Long-pressing your power button (5 seconds or longer)
  # to do a hard reset is handled by your machine’s BIOS/EFI and thus still possible.
  # (https://wiki.nixos.org/wiki/Systemd/logind)
  services.logind.settings.Login.HandlePowerKey = "ignore"; # started working after a reboot

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # Maps capslock to escape when pressed and control when held.
            capslock = "overload(control, esc)";
            # Remaps the escape key to capslock
            # esc = "capslock";
          };
        };
      };
    };
  };

  # laptop battery info via `upower --dump`
  services.upower.enable = true;
}
