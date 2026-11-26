{
  flake.modules.homeManager.doom =
    { config, ... }:
    {
      xdg.configFile."doom".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/syscfg/doom/.config/doom";
    };
}
