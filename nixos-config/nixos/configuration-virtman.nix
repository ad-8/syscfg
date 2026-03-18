{
  config,
  lib, pkgs,
  ...
}:

{
  options = {
    configVirtman.enable = lib.mkEnableOption "Enable libvirtd and virt-manager";
  };

  config = lib.mkIf config.configVirtman.enable {
    # https://wiki.nixos.org/wiki/Virt-manager
    # - enable network: `sudo virsh net-autostart default`
    # - start network for current boot: `sudo virsh net-start default`
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    users.users.ax.extraGroups = [
      "libvirtd"
    ];

    environment.systemPackages = with pkgs; [
      virtiofsd # e.g. needed to share NFS mount with VM
    ];
  };
}
