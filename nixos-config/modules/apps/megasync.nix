{
  flake.modules.homeManager.megasync = {
    services.megasync = {
      enable = true;
      forceWayland = true;
    };
  };
}
