{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configPrinting.enable = lib.mkEnableOption "Enable auto-discovery of network printers (IPP Everywhere)";
  };

  config = lib.mkIf config.configPrinting.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };

    environment.systemPackages = [
      pkgs.system-config-printer
    ];
  };
}
