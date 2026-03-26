{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    pkgsCore.enable = lib.mkEnableOption "Enable core pkgs";
  };

  config = lib.mkIf config.pkgsCore.enable {
    home.packages = with pkgs; [
      foot
      tealdeer
    ];
  };
}
