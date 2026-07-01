{ pkgs, ... }:

{
  imports = [
    ../config-core.nix
    ../all-modules.nix
  ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest

  configAudio.enable = true;

  # without this, home-manager fails to start on boot (oxwm, unlike xfce, doesn't pull it in)
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    btop
    dmenu
    maim
    unzip
    xclip
  ];

  services.xserver = {
    enable = true;
    windowManager.oxwm.enable = true;
    # `oxwm` from tty does not work -> `exec oxwm` in `.xinitrc`
    displayManager.startx.enable = true;
  };


  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

}
