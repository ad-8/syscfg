{ ... }:

{
  imports = [
    ../config-core.nix
    ../ax-configs.nix
  ];

  configExtra.enable = false;
  configClamav.enable = false;
  configPrinting.enable = false;
  configVirtman.enable = false;
  configDistrobox.enable = false;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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
