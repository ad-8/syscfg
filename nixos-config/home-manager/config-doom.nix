{
  config,
  lib,
  ...
}:

{
  options = {
    configDoom.enable = lib.mkEnableOption "Enable doom config";
  };

  config = lib.mkIf config.configDoom.enable {
    xdg.configFile."doom".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/syscfg/dotfiles/doom/.config/doom";
  };
}
