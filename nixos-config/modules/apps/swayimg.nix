{
  flake.modules.homeManager.swayimg = {
    programs.swayimg = {
      enable = true;
      settings = {
        list.all = "yes";
        gallery.pstore = "yes";
        "keys.gallery" = {
          h = "step_left";
          j = "step_down";
          k = "step_up";
          l = "step_right";
          g = "first_file";
          "Shift+g" = "last_file";
          "Ctrl+d" = "page_down";
          "Ctrl+u" = "page_up";
          "Shift+Delete" = "none";
        };
        "keys.viewer" = {
          h = "prev_file";
          l = "next_file";
          g = "first_file";
          "Shift+g" = "last_file";
          Escape = "mode gallery";
          "Shift+Delete" = "none";
        };
      };
    };
  };
}
