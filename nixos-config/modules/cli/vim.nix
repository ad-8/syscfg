{
  flake.modules.homeManager.vim =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.vim ];
      home.file.".vimrc".source = ./vim/vimrc;
    };
}
