{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    configWebApps.enable = lib.mkEnableOption "Enable WebApps";
  };

  config = lib.mkIf config.configWebApps.enable {
    xdg.desktopEntries = {
      proton-mail = {
        name = "Proton Mail";
        genericName = "Proton Mail";
        exec = "${pkgs.chromium}/bin/chromium --app=\"https://mail.proton.me\"";
        # TODO
        # icon  = "$HOME/.local/share/icons/proton-calendar.png";
        terminal = false;
        # TODO which k/v pairs are required?
        # categories = [ "Network" "WebBrowser" ];
        # mimeType = [ "text/html" "text/xml" ];
      };
      proton-calendar = {
        name = "Proton Calendar";
        genericName = "Proton Calendar";
        exec = "${pkgs.chromium}/bin/chromium --app=\"https://calendar.proton.me\"";
        terminal = false;
      };
      nixpkgs = {
        name = "Nix Search Packages";
        exec = "${pkgs.chromium}/bin/chromium --app=\"https://search.nixos.org/packages\"";
        terminal = false;
      };
      claude = {
        name = "Claude";
        genericName = "Claude";
        exec = "${pkgs.chromium}/bin/chromium --app=\"https://claude.ai\"";
        terminal = false;
      };
    };
  };
}
