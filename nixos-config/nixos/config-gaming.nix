{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configGaming.enable = lib.mkEnableOption "Enable Steam, Heroic, and gaming tools";
  };

  config = lib.mkIf config.configGaming.enable {
    programs.steam.enable = true;
    # heroic wiki recommends
    programs.gamescope.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      (heroic.override {
        extraPkgs = pkgs: [
          pkgs.gamescope
          pkgs.mangohud
        ];
      })
    ];
  };
}
