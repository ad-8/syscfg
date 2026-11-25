{
  config,
  lib,
  ...
}:

{
  options = {
    configWaybar.enable = lib.mkEnableOption "Enable waybar config";
  };

  config = lib.mkIf config.configWaybar.enable {
    xdg.configFile = {
      "waybar/compositor-mango.json".source = ./files/waybar/compositor-mango.json;
      "waybar/config".source = ./files/waybar/config;
      "waybar/config-minimal".source = ./files/waybar/config-minimal;
      "waybar/snowflake.xml".source = ./files/waybar/snowflake.xml;
      "waybar/style.css".source = ./files/waybar/style.css;
    };
  };
}
