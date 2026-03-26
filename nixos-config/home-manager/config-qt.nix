{
  config,
  lib,
  pkgs,
  ...
}:

{

  options = {
    configQt.enable = lib.mkEnableOption "Enable Qt config";
  };

  config = lib.mkIf config.configQt.enable {
    qt = {
      enable = true;
      platformTheme.name = "qtct";
      style.name = "kvantum";
    };

    xdg.configFile = {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=Nordic
      '';

      "Kvantum/Nordic".source = "${pkgs.nordic}/share/Kvantum/Nordic";
    };
  };
}
