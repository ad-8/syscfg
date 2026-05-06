{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configPrinting.enable = lib.mkEnableOption "Enable CUPS and install printing pkgs";
  };

  config = lib.mkIf config.configPrinting.enable {
    
    services.printing = {
      enable = true; # Enable CUPS to print documents.
      # drivers = [ pkgs.hplip ]; # printer works w/ or w/o this
    };

    environment.systemPackages = with pkgs; [
      system-config-printer
    ];
  };
}
