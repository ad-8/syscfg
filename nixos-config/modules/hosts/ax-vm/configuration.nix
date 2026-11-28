{ config, inputs, ... }:

let
  modules = config.flake.modules;
in
{
  flake.nixosConfigurations.ax-vm = inputs.nixpkgs-stable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with modules.nixos; [
      # foundation
      core
      home-manager

      # role
      audio

      # cli
      btop

      # host
      ax-vm
      {
        home-manager.users.ax.imports = with modules.homeManager; [
          emacs
          fastfetch
          git
          pkgs-core
          starship
          tmux
          vim
        ];
      }
    ];
  };

  flake.modules.nixos.ax-vm =
    { pkgs, ... }:

    {
      imports = [
        ./_hardware-configuration.nix
      ];

      services.qemuGuest.enable = true;

      # kept from when ax-vm had home-manager's gtk settings (dconf writes); likely unneeded since 4976ee47
      programs.dconf.enable = true;

      environment.systemPackages = with pkgs; [
        unzip
      ];

      networking.hostName = "ax-vm";

      services.openssh.enable = true;

      system.stateVersion = "25.11";
    };
}
