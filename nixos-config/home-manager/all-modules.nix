{ lib, ... }:

{
  imports = [
    ./config-auth-agent.nix
    ./config-btop.nix
    ./config-emacs.nix
    ./config-fastfetch.nix
    ./config-foot.nix
    ./config-git.nix
    ./config-gtk.nix
    ./config-megasync.nix
    ./config-mime.nix
    ./config-mpv.nix
    ./config-qt.nix
    ./config-secret-service.nix
    ./config-starship.nix
    ./config-swappy.nix
    ./config-tealdeer.nix
    ./config-webapps.nix
    ./pkgs-core.nix
    ./pkgs-dev.nix
    ./pkgs-extra.nix
    ./pkgs-gui.nix
    ./pkgs-wm.nix
  ];

  pkgsCore.enable = lib.mkDefault true;
}
