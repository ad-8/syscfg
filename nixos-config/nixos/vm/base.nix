{ ... }:

{
  imports = [
    ../config-core.nix
    ../all-modules.nix
  ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest

  configAudio.enable = true;

  environment.systemPackages = [ ];

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";

}
