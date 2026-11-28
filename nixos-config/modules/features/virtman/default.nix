{
  flake.modules.nixos.virtman =
    { pkgs, ... }:
    {
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
