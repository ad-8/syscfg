{
  flake.modules.nixos.audiobookshelf = {
    services.audiobookshelf = {
      enable = true;
      host = "0.0.0.0";
      port = 8000;
      user = "ax";
      group = "users";
      openFirewall = true;
    };
  };
}
