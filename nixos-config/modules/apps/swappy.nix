{
  flake.modules.homeManager.swappy = {
    programs.swappy = {
      enable = true;
      settings = {
        Default = {
          save_dir = "$HOME/sync/screenshots/$(date +%Y)";
          save_filename_format = "%Y%m%d-%H%M%S_screenshot-swappy.png";
          show_panel = true;
        };
      };
    };
  };
}
