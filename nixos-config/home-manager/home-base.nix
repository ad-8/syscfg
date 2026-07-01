{ ... }:

{
  imports = [
    ./all-modules.nix
  ];

  home.stateVersion = "25.05";
  home.username = "ax";
  home.homeDirectory = "/home/ax";
  home.packages = [ ];

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo 'home-manager seems to be working :)'";
    };
  };
}
