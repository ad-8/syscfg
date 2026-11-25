{ lib, ... }:

{
  imports = [
    ./config-auth-agent.nix
    ./config-btop.nix
    ./config-clojure.nix
    ./config-doom.nix
    ./config-emacs.nix
    ./config-fastfetch.nix
    ./config-fish.nix
    ./config-git.nix
    ./config-gtk.nix
    ./config-megasync.nix
    ./config-mime.nix
    ./config-mpv.nix
    ./config-qt.nix
    ./config-restic.nix
    ./config-secret-service.nix
    ./config-swappy.nix
    ./config-tealdeer.nix
    ./config-tmux.nix
    ./config-vim.nix
    ./config-webapps.nix
    ./pkgs-core.nix
    ./pkgs-dev.nix
    ./pkgs-extra.nix
    ./pkgs-gui.nix
  ];

  pkgsCore.enable = lib.mkDefault true;
}
