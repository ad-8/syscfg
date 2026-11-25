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

  configAuthAgent.enable = true;
  configClojure.enable = true;
  configDoom.enable = true;
  configEmacs.enable = true;
  configGtk.enable = true;
  configMegasync.enable = false;
  configMime.enable = true;
  configMpv.enable = true;
  configQt.enable = false;
  configRestic.enable = true;
  configSecretService.enable = false;
  configSwappy.enable = true;
  configTealdeer.enable = true;
  configWebApps.enable = true;
}
