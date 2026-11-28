{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
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

  flake.modules.homeManager.gaming = {
    programs.mangohud.enable = true;
  };
}
