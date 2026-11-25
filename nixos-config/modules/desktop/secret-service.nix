{
  flake.modules.homeManager.secret-service =
    { pkgs, ... }:
    {
      # https://wiki.nixos.org/wiki/Secret_Service
      services.gnome-keyring.enable = true;
      home.packages = [ pkgs.gcr ]; # Provides org.gnome.keyring.SystemPrompter
    };
}
