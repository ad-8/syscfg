# One Big Beautiful Repository
Now also includes my NixOS config in `nixos`.

## dotfiles
From the root dotfiles folder:  
`stow -vR --target=$HOME *` or `stow -vR --target=$HOME niri/`  
To remove all:  
`stow -D --target=$HOME *`

## scripts
Collection of maintained and long-forgotten scripts.

## nixos
Second time's the charm?


### Installation with LUKS -> convert to flake-based config

Choose `GNOME` when booting the `Graphical ISO image` (uses the Calamares installer) *and* choose `GNOME` instead of `No desktop` in the installer for an easy initial WiFi setup.

Post-install steps:  
1. Add this line to `/etc/nixos/configuration.nix`:
```nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Also add `git` and `vim` to `environment.systemPackages` for the next steps.

2. `sudo nixos-rebuild switch`

3. `git clone https://github.com/ad-8/syscfg`

4. `cp /etc/nixos/hardware-configuration.nix ~/syscfg/nixos/hosts/<host>/` 

5. if *not* using LUKS, skip this step  
   add this line from `/etc/nixos/configuration.nix` to `~/syscfg/nixos/hosts/<host>/configuration.nix`  
   (or replace existing equivalent)
```nix
   boot.initrd.luks.devices... = "/dev/disk/by-uuid/..."
```

6. `sudo nixos-rebuild boot --flake ~/syscfg/nixos#<host>`, finally reboot and enjoy

