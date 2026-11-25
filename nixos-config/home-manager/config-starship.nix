{
  config,
  lib,
  ...
}:

{
  options = {
    configStarship.enable = lib.mkEnableOption "Enable starship config";
  };

  config = lib.mkIf config.configStarship.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = false;
      settings = import ../shared/starship.nix;
    };
  };
}
