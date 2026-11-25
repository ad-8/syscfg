{
  flake.modules.homeManager.tmux = {
    home.file.".tmux.conf".source = ./tmux/.tmux.conf;
  };

  flake.modules.nixos.tmux = {
    environment.etc."tmux.conf".source = ./tmux/.tmux.conf;
  };
}
