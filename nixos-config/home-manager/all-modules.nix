{ lib, ... }:

{
  imports = [
    ./config-auth-agent.nix
    ./config-emacs.nix
    ./config-git.nix
    ./config-gtk.nix
    ./config-megasync.nix
    ./config-mime.nix
    ./config-qt.nix
    ./config-secret-service.nix
    ./config-webapps.nix
    ./pkgs-core.nix
    ./pkgs-dev.nix
    ./pkgs-extra.nix
    ./pkgs-gui.nix
    ./pkgs-wm.nix
  ];

  pkgsCore.enable = lib.mkDefault true;
}
