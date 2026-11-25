{
  config,
  lib,
  ...
}:

{
  options = {
    configVim.enable = lib.mkEnableOption "Enable vim config";
  };

  config = lib.mkIf config.configVim.enable {
    home.file.".vimrc".source = ../shared/vim/vimrc;
  };
}
