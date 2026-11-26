{
  flake.modules.nixos.syncthing = {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      group = "users";
      user = "ax";
      dataDir = "/home/ax/syncthing"; # Default folder for new synced folders
      configDir = "/home/ax/.config/syncthing"; # Folder for Syncthing's settings and keys
    };
  };
}
