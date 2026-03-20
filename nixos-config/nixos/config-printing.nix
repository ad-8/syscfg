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
    # Enable CUPS to print documents.
    services.printing.enable = true;

    environment.systemPackages = with pkgs; [
      hplip
      system-config-printer
    ];
  };
}
