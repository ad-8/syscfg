{
  config,
  lib,
  ...
}:

{
  options = {
    configFastfetch.enable = lib.mkEnableOption "Enable fastfetch config";
  };

  config = lib.mkIf config.configFastfetch.enable {
    programs.fastfetch = {
      enable = true;
      settings = import ../shared/fastfetch.nix;
    };
  };
}
