{ lib, ... }:

{
  imports = [
    ./config-auth-agent.nix
    ./config-btop.nix
    ./config-clojure.nix
    ./config-doom.nix
    ./config-dunst.nix
    ./config-emacs.nix
    ./config-fastfetch.nix
    ./config-fish.nix
    ./config-foot.nix
    ./config-git.nix
    ./config-gtk.nix
    ./config-mango.nix
    ./config-megasync.nix
    ./config-mime.nix
    ./config-mpv.nix
    ./config-qt.nix
    ./config-restic.nix
    ./config-rofi.nix
    ./config-secret-service.nix
    ./config-starship.nix
    ./config-swappy.nix
    ./config-tealdeer.nix
    ./config-tmux.nix
    ./config-vim.nix
    ./config-waybar.nix
    ./config-webapps.nix
    ./pkgs-core.nix
    ./pkgs-dev.nix
    ./pkgs-extra.nix
    ./pkgs-gui.nix
    ./pkgs-wm.nix
  ];

  pkgsCore.enable = lib.mkDefault true;
}
