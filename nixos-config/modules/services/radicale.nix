{
  flake.modules.nixos.radicale = {
    networking.firewall.allowedTCPPorts = [ 5232 ];

    services.radicale = {
      enable = true;
      settings = {
        server.hosts = [ "0.0.0.0:5232" ];
        auth = {
          type = "htpasswd";
          # file not managed by NixOS (contains hashed passwords) — recreate with (see radicale docs):
          # htpasswd -B -c /var/lib/radicale/radicale_users ax
          htpasswd_filename = "/var/lib/radicale/radicale_users";
          htpasswd_encryption = "bcrypt";
        };
      };
    };
  };
}
