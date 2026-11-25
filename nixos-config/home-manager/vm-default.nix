{ ... }:

{
  imports = [
    ./home-base.nix
  ];

  # pkgsCore stays on via all-modules.nix
  configEmacs.enable = true;
}
