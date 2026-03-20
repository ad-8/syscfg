{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configDistrobox.enable = lib.mkEnableOption "Enable distrobox";
  };

  config = lib.mkIf config.configDistrobox.enable {

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    environment.systemPackages = [ pkgs.distrobox ];
  };
}
