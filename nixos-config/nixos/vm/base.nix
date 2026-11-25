{ pkgs, ... }:

{
  imports = [
    ../config-core.nix
    ../all-modules.nix
  ];

  services.qemuGuest.enable = true;

  configAudio.enable = true;

  # kept from when ax-vm had home-manager's gtk settings (dconf writes); likely unneeded since 4976ee47
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    btop
    unzip
  ];
}
