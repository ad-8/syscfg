{
  flake.modules.homeManager.mpv = {
    programs.mpv = {
      enable = true;
      config = {
        hwdec = "auto-safe";
      };
    };
  };
}
