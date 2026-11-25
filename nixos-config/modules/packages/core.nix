{
  flake.modules.homeManager.pkgs-core =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        foot
        tealdeer
      ];
    };
}
