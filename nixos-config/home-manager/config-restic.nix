{
  config,
  lib,
  ...
}:

{
  options = {
    configRestic.enable = lib.mkEnableOption "Enable restic exclude config";
  };

  config = lib.mkIf config.configRestic.enable {
    home.file.".restic-exclude".source = ./files/restic/.restic-exclude;
  };
}
