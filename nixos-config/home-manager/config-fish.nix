{
  config,
  lib,
  ...
}:

{
  options = {
    configFish.enable = lib.mkEnableOption "Enable fish config";
  };

  config = lib.mkIf config.configFish.enable {
    xdg.configFile = {
      "fish/config.fish".source = ../shared/fish/config.fish;
      "fish/nnn.fish".source = ../shared/fish/nnn.fish;
      "fish/functions/rfv.fish".source = ../shared/fish/functions/rfv.fish;
      "fish/functions/rfvuuu.fish".source = ../shared/fish/functions/rfvuuu.fish;
      "fish/functions/y.fish".source = ../shared/fish/functions/y.fish;
    };
  };
}
