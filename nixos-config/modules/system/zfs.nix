{
  flake.modules.nixos.zfs = {
    # setup from https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;
  };
}
