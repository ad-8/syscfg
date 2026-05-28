{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    pkgsExtra.enable = lib.mkEnableOption "Enable extra pkgs";
  };

  config = lib.mkIf config.pkgsExtra.enable {
    home.packages = with pkgs; [
      age
      btop
      chafa
      gum
      imagemagick
      inxi # Full featured CLI system information tool
      iotop-c
      lm_sensors # provides `sensors` cmd to show cpu temp etc.
      pciutils # lspci and more
      pdftk
      smartmontools
      steam-run
      unzip
      usbutils # lsusb and more
      wireguard-tools
    ];
  };
}
