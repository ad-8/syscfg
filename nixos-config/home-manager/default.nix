{ ... }:

{
  imports = [
    ./home-base.nix
  ];

  # https://github.com/vimjoyer/modularize-video (as seen in https://www.youtube.com/watch?v=vYc6IzKvAJQ)
  # pkgsCore.enable = true; # enabled by default, see all-modules.nix
  pkgsDev.enable = true;
  pkgsExtra.enable = true;
  pkgsGui.enable = true;
  pkgsWm.enable = true;

  configAuthAgent.enable = true;
  configBtop.enable = true;
  configClojure.enable = true;
  configDoom.enable = true;
  configDunst.enable = true;
  configEmacs.enable = true;
  configFastfetch.enable = true;
  configFish.enable = true;
  configFoot.enable = true;
  configGit.enable = true;
  configGtk.enable = true;
  configMango.enable = true;
  configMegasync.enable = false;
  configMime.enable = true;
  configMpv.enable = true;
  configQt.enable = false;
  configRestic.enable = true;
  configRofi.enable = true;
  configSecretService.enable = false;
  configStarship.enable = true;
  configSwappy.enable = true;
  configTealdeer.enable = true;
  configTmux.enable = true;
  configVim.enable = true;
  configWaybar.enable = true;
  configWebApps.enable = true;
}
