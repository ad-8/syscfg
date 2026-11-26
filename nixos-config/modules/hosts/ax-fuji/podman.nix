{
  flake.modules.nixos.ax-fuji = {
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
