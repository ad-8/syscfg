{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configClamav.enable = lib.mkEnableOption "Enable ClamAV";
  };

  config = lib.mkIf config.configClamav.enable {

    services.clamav.daemon.enable = true;
    services.clamav.updater.enable = true;

    environment.systemPackages = with pkgs; [
      clamav
    ];
  };
}
