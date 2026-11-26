{
  flake.modules.nixos.podman =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.podman-compose ];

      users.users.ax = {
        extraGroups = [ "podman" ];
        # start ax's user services at boot, without a login (for podman-restart)
        linger = true;
      };

      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;
          dockerCompat = true; # Create an alias mapping docker to podman.
          defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
        };
      };

      systemd.user.services.podman-restart.wantedBy = [ "default.target" ];
    };
}
