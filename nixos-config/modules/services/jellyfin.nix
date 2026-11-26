{
  flake.modules.nixos.jellyfin =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # services.jellyfin only installs pkgs.jellyfin; web and ffmpeg must be explicit
        jellyfin-ffmpeg
        jellyfin-web
      ];

      users.users.ax.extraGroups = [ "render" ];

      services.jellyfin = {
        enable = true;
        openFirewall = true;
        user = "ax";
        hardwareAcceleration = {
          enable = true;
          type = "vaapi";
          device = "/dev/dri/renderD128";
        };
        forceEncodingConfig = true;
        transcoding = {
          enableHardwareEncoding = true;
          hardwareDecodingCodecs = {
            h264 = true;
            hevc = true;
            hevc10bit = true;
            vp8 = true;
            vp9 = true;
            mpeg2 = true;
            vc1 = true;
          };
        };
      };
    };
}
