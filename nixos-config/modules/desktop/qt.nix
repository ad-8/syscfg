{
  flake.modules.homeManager.qt =
    { pkgs, ... }:
    {
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
