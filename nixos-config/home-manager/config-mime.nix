{ config, lib, ... }:

# https://wiki.nixos.org/wiki/Default_applications
#
# To list all .desktop-files, run
# ls /run/current-system/sw/share/applications # for global packages
# ls /etc/profiles/per-user/$(id -n -u)/share/applications # for user packages
# ls ~/.nix-profile/share/applications # for home-manager packages
let
  audioPlayer = [ "mpv.desktop" ];
  browser = [ "firefox.desktop" ];
  emacs = [ "emacs.desktop" ];
  imageViewer = [ "org.xfce.ristretto.desktop" ];
  pdfReader = [ "org.kde.okular.desktop" ];
  simpleTextEditor = [ "org.xfce.mousepad.desktop" ];
  videoPlayer = [ "mpv.desktop" ];
in
{
  options = {
    configMime.enable = lib.mkEnableOption "Enable configMime";
  };

  config = lib.mkIf config.configMime.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # HTML-files and URLs
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        # Images
        "image/gif" = imageViewer;
        "image/jpeg" = imageViewer;
        "image/png" = imageViewer;
        "image/webp" = imageViewer;
        "image/*" = imageViewer;
        # Documents
        "application/json" = browser;
        "application/pdf" = pdfReader;
        "text/plain" = simpleTextEditor;
        "text/markdown" = emacs;
        "text/org" = emacs;
        "text/*" = simpleTextEditor;
        # Audio
        "audio/mpeg" = audioPlayer; # .mp3
        "audio/ogg" = audioPlayer;
        "audio/flac" = audioPlayer;
        "audio/wav" = audioPlayer;
        "audio/x-wav" = audioPlayer;
        "audio/aac" = audioPlayer;
        "audio/mp4" = audioPlayer; # .m4a
        "audio/x-m4a" = audioPlayer;
        "audio/*" = audioPlayer;
        # Video
        "video/mp4" = videoPlayer;
        "video/webm" = videoPlayer;
        "video/x-matroska" = videoPlayer; # .mkv
        "video/quicktime" = videoPlayer; # .mov
        "video/x-msvideo" = videoPlayer; # .avi
        "video/x-ms-wmv" = videoPlayer; # .wmv
        "video/ogg" = videoPlayer; # .ogv (Ogg video)
        "video/*" = videoPlayer;
      };
    };
  };
}
