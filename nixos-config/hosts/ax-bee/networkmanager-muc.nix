{ config, ... }:

{
  # declarative version of the muc wireguard profile (home network split
  # tunnel), previously only an imported keyfile on the host; rendered to
  # /run/NetworkManager/system-connections/muc.nmconnection with the
  # secrets substituted from the agenix env file
  age.secrets.ax-bee-networkmanager-muc.file = ../../secrets/ax-bee-networkmanager-muc.age;

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.age.secrets.ax-bee-networkmanager-muc.path ];
    profiles.muc = {
      connection = {
        id = "muc";
        uuid = "7e453f4d-f8ab-4c68-a2ad-56bda336b09a";
        type = "wireguard";
        autoconnect = false;
        interface-name = "muc";
      };
      wireguard = {
        private-key = "$MUC_PRIVATE_KEY";
      };
      # the section name is the peer's public key (not secret)
      "wireguard-peer.1lJ2SvS4KCzMKosbbnorOy52mw9DT8vzyRE0JQox8n8=" = {
        endpoint = "$MUC_ENDPOINT";
        preshared-key = "$MUC_PSK";
        preshared-key-flags = 0;
        persistent-keepalive = 25;
        allowed-ips = "192.168.178.0/24;fd42:3d38:8f1c::/64;";
      };
      ipv4 = {
        address1 = "192.168.178.203/24";
        dns = "192.168.178.1;";
        dns-search = "fritz.box;";
        method = "manual";
        never-default = true;
      };
      ipv6 = {
        addr-gen-mode = "default";
        address1 = "fd42:3d38:8f1c::203/64";
        dns = "$MUC_DNS6;";
        dns-search = "fritz.box;";
        method = "manual";
        never-default = true;
      };
    };
  };
}
