{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  services.qemuGuest.enable = true;

  # kept from when ax-vm had home-manager's gtk settings (dconf writes); likely unneeded since 4976ee47
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    btop
    unzip
  ];

  networking.hostName = "ax-vm";

  services.openssh.enable = true;

  system.stateVersion = "25.11";
}
