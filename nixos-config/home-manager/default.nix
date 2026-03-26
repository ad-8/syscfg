{ ... }:

{
  imports = [
    ./all-modules.nix
  ];

  # https://github.com/vimjoyer/modularize-video (as seen in https://www.youtube.com/watch?v=vYc6IzKvAJQ)
  # pkgsCore.enable = true; # enabled by default, see all-modules.nix
  pkgsDev.enable = true;
  pkgsExtra.enable = true;
  pkgsGui.enable = true;
  pkgsWm.enable = true;

  configAuthAgent.enable = true;
  configGit.enable = true;
  configGtk.enable = true;
  configMegasync.enable = false;
  configMime.enable = true;
  configQt.enable = true;
  configSecretService.enable = false;
  configWebApps.enable = true;

  home.stateVersion = "25.05";
  home.username = "ax";
  home.homeDirectory = "/home/ax";
  home.packages = [];

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo 'home-manager seems to be working :)'";
    };
  };
}
