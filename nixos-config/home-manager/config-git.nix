{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configGit.enable = lib.mkEnableOption "Enable git config";
  };

  config = lib.mkIf config.configGit.enable {
    programs.git = {
      enable = true;
      settings = import ../shared/git.nix { inherit pkgs; };
    };
  };
}
