let
  doomDir = "syscfg/doom/.config/doom";
in
{
  flake.modules.homeManager.doom =
    { config, ... }:
    {
      xdg.configFile."doom".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${doomDir}";
    };
}
