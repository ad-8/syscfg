{
  config,
  lib,
  ...
}:

{
  options = {
    configBtop.enable = lib.mkEnableOption "Enable btop config";
  };

  config = lib.mkIf config.configBtop.enable {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "active";
        save_config_on_exit = false;
      };
    };
  };
}
