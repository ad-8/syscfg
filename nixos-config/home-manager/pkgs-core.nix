{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    pkgsCore.enable = lib.mkEnableOption "Enable core pkgs";
  };

  config = lib.mkIf config.pkgsCore.enable {
    home.packages = with pkgs; [
      babashka
      bat
      delta
      emacs
      eza
      fastfetch
      foot
      fzf
      htop
      starship
      stow
      tealdeer
      tokei
      zoxide
    ];
  };
}
