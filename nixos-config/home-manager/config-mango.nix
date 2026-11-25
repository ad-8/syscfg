{
  config,
  lib,
  ...
}:

{
  options = {
    configMango.enable = lib.mkEnableOption "Enable mango config";
  };

  config = lib.mkIf config.configMango.enable {
    xdg.configFile."mango/config.conf".source = ./files/mango/config.conf;
  };
}
