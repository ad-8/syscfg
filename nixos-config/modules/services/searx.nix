{ config, ... }:

let
  modules = config.flake.modules;
in
{
  flake.modules.nixos.searx =
    { config, ... }:
    {
      imports = [ modules.nixos.agenix ];

      networking.firewall.allowedTCPPorts = [ 8888 ];

      age.secrets.searx-secret-key.file = ../../secrets/searx-secret-key.age;

      services.searx = {
        enable = true;
        redisCreateLocally = true;
        environmentFile = config.age.secrets.searx-secret-key.path;
        settings.server = {
          bind_address = "0.0.0.0";
          port = 8888;
          # TODO sever.image_proxy ?
        };
      };
    };
}
