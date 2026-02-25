{
  pkgs,
  ...
}:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "de";
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    ncdu
    tmux
  ];

  users.users.ax = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "ax";
    extraGroups = [
      "i2c"
      "libvirtd"
      "networkmanager"
      "podman"
      "video"
      "wheel"
    ];
    packages = with pkgs; [
      git
    ];
  };

  programs.fish.enable = true;

  security.sudo = {
    extraConfig = ''
      Defaults timestamp_timeout=30
    '';
    extraRules = [
      {
        users = [ "ax" ];
        commands = [
          {
            # TODO apparently installing wg-quick as *system* pkg and using that path is more stable
            command = "/etc/profiles/per-user/ax/bin/wg-quick";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

}
