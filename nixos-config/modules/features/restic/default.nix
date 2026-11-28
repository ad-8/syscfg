{
  flake.modules.homeManager.restic = {
    home.file.".restic-exclude".source = ./.restic-exclude;
  };

  flake.modules.nixos.restic =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        restic
        rclone
      ];
    };
}
