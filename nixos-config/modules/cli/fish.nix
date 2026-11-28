{
  flake.modules.homeManager.fish = {
    xdg.configFile = {
      "fish/config.fish".source = ./fish/config.fish;
      "fish/nnn.fish".source = ./fish/nnn.fish;
      "fish/functions/rfv.fish".source = ./fish/functions/rfv.fish;
      "fish/functions/rfvuuu.fish".source = ./fish/functions/rfvuuu.fish;
      "fish/functions/y.fish".source = ./fish/functions/y.fish;
    };
  };
}
