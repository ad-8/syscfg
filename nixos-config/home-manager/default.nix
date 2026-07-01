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
  configEmacs.enable = true;
  configGit.enable = true;
  configGtk.enable = true;
  configMegasync.enable = false;
  configMime.enable = true;
  configQt.enable = false;
  configSecretService.enable = false;
  configWebApps.enable = true;
}
