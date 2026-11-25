{
  config,
  lib,
  ...
}:

{
  options = {
    configRofi.enable = lib.mkEnableOption "Enable rofi config";
  };

  config = lib.mkIf config.configRofi.enable {
    xdg.configFile = {
      "rofi/config.rasi".source = ./files/rofi/config.rasi;
      "rofi/picker.rasi".source = ./files/rofi/picker.rasi;
    };
  };
}
