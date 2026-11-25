{
  flake.modules.homeManager.vim = {
    home.file.".vimrc".source = ./vim/vimrc;
  };

  flake.modules.nixos.vim = {
    environment.etc."vimrc".source = ./vim/vimrc;
    environment.variables.VIMINIT = "source /etc/vimrc";
  };
}
