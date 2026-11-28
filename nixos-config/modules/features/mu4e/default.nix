{
  flake.modules.nixos.mu4e = {
    nixpkgs.overlays = [
      (final: prev: {
        emacsWithMu4e = (final.emacsPackagesFor final.emacs).emacsWithPackages (epkgs: [ epkgs.mu4e ]);
      })
    ];
  };

  flake.modules.homeManager.mu4e =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mu
        isync
      ];
    };
}
