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

  flake.modules.nixos.doom-link = {
    systemd.tmpfiles.rules = [
      "d /home/ax/.config 0700 ax users -"
      "L /home/ax/.config/doom - - - - /home/ax/${doomDir}"
    ];
  };
}
