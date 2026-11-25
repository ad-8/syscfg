{
  config,
  lib,
  ...
}:

{
  options = {
    configBtop.enable = lib.mkEnableOption "Enable btop config";
  };

  config = lib.mkIf config.configBtop.enable {
    programs.btop = {
      enable = true;
      settings = import ../shared/btop.nix;
    };
  };
}
