{
  config,
  lib,
  ...
}:

{
  options = {
    configTealdeer.enable = lib.mkEnableOption "Enable tealdeer config";
  };

  config = lib.mkIf config.configTealdeer.enable {
    programs.tealdeer = {
      enable = true;
      enableAutoUpdates = false;
      settings = {
        style = {
          description = {
            underline = false;
            bold = false;
            italic = false;
          };
          command_name = {
            foreground = "cyan";
            underline = false;
            bold = false;
            italic = false;
          };
          example_text = {
            foreground = "green";
            underline = false;
            bold = false;
            italic = false;
          };
          example_code = {
            foreground = "cyan";
            underline = false;
            bold = false;
            italic = false;
          };
          example_variable = {
            foreground = "cyan";
            underline = true;
            bold = false;
            italic = false;
          };
        };
        display = {
          compact = false;
          use_pager = false;
          show_title = false;
        };
        updates = {
          auto_update = true;
          auto_update_interval_hours = 72;
          archive_source = "https://github.com/tldr-pages/tldr/releases/latest/download/";
          tls_backend = "rustls-with-native-roots";
        };
      };
    };
  };
}
