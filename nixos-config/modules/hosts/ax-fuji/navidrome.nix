{
  flake.modules.nixos.ax-fuji = {
    services.navidrome = {
      enable = true;
      openFirewall = true;
      settings = {
        Address = "0.0.0.0";
        MusicFolder = "/nas/tmp/music-discographies";
        # verify with `journalctl -u navidrome -b | grep -E "DISABLED|scan"`
        Scanner.Enabled = false;
      };
    };

    # don't start navidrome before the NAS music share is mounted, or it serves an empty library
    systemd.services.navidrome.unitConfig.RequiresMountsFor = [ "/nas/tmp/music-discographies" ];
  };
}
