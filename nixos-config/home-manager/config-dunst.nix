{
  config,
  lib,
  ...
}:

{
  options = {
    configDunst.enable = lib.mkEnableOption "Enable dunst config";
  };

  config = lib.mkIf config.configDunst.enable {
    xdg.configFile."dunst/dunstrc".source = ./files/dunst/dunstrc;
  };
}
