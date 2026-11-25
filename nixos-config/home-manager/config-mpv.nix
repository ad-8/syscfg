{
  config,
  lib,
  ...
}:

{
  options = {
    configMpv.enable = lib.mkEnableOption "Enable mpv config";
  };

  config = lib.mkIf config.configMpv.enable {
    programs.mpv = {
      enable = true;
      config = {
        hwdec = "auto-safe";
      };
    };
  };
}
