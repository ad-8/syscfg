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
    babashka
    bat
    delta
    emacs
    eza
    fastfetch
    fd
    file
    fzf
    git
    htop
    ncdu
    nh
    (nnn.override { withNerdIcons = true; })
    psmisc # provides killall
    ripgrep
    starship
    stow
    tmux
    tokei
    tree
    vim
    wget
    zoxide
  ];

  users.users.ax = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "ax";
    extraGroups = [
      "networkmanager"
      "video"
      "wheel"
    ];
    packages = with pkgs; [
      neovim
    ];
  };

  programs.fish.enable = true;

  # ensure the client has the necessary NFS utilities installed
  boot.supportedFilesystems = [ "nfs" ];

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

  # verify with `systemctl [--user] show | grep 10s`
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
    DefaultDeviceTimeoutSec = "10s";
  };
  systemd.user.extraConfig = ''
    DefaultTimeoutStartSec=10s
    DefaultTimeoutStopSec=10s
  '';
}
