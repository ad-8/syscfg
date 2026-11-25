{
  flake.modules.nixos.clamav =
    { pkgs, ... }:
    {
      services.clamav.updater.enable = true;

      environment.systemPackages = with pkgs; [
        clamav
      ];
    };
}
