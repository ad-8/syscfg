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

  flake.modules.nixos.fish = {
    environment.etc = {
      "fish/ax/config.fish".source = ./fish/config.fish;
      "fish/ax/nnn.fish".source = ./fish/nnn.fish;
      "fish/ax/functions/rfv.fish".source = ./fish/functions/rfv.fish;
      "fish/ax/functions/rfvuuu.fish".source = ./fish/functions/rfvuuu.fish;
      "fish/ax/functions/y.fish".source = ./fish/functions/y.fish;
    };
    programs.fish.shellInit = ''
      set -a fish_function_path /etc/fish/ax/functions
      source /etc/fish/ax/config.fish
    '';
  };
}
