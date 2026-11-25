{
  config,
  lib,
  ...
}:

{
  options = {
    configTmux.enable = lib.mkEnableOption "Enable tmux config";
  };

  config = lib.mkIf config.configTmux.enable {
    home.file.".tmux.conf".source = ../shared/tmux/.tmux.conf;
  };
}
