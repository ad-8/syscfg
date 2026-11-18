# One Big Beautiful Repository

## I. dotfiles
From the root dotfiles folder:  
`stow -vR --target=$HOME *` or `stow -vR --target=$HOME niri/`  
To remove all:  
`stow -D --target=$HOME *`

### After stowing on a new machine
Run the theme switcher once to create the per-app `active-theme.*` symlinks that the configs include/source:

```sh
bb ~/syscfg/scripts/bb/switch_theme.clj <theme-name>
```

Replace `<theme-name>` with a concrete value, like `nord`.

For kwm, run the switcher before first starting or reloading the updated config.
After switching themes in a running kwm session, press Super+Shift+R to apply
the bar and border colors.

Run the switcher again after pulling theme changes, and after editing
`dotfiles/wlr-which-key/.config/wlr-which-key/menu.yaml`. The menu updates
only when the switcher runs. The first run has to be from a terminal, since
`c t` and `c T` are bindings in that menu.

### FreeBSD laptop (ax-lat, sway)
The keyboard has no `<>` key next to left Shift. The `xkb` package adds a
layout, `de-ansi`, that puts `<` `>` `|` on AltGr+y/x/c:

```sh
stow -v --target=$HOME xkb
```

Then enable it on this host only, as root, in `/etc/sway/config.d/keyboard`
(the sway config includes `/etc/sway/config.d/*`; other hosts keep plain `de`):

```
input type:keyboard xkb_layout "de-ansi"
```

Reload sway with Super+Shift+R.

#### Sound: mixer vs PulseAudio
FreeBSD's sound system is OSS; `mixer` sets its volume, for every app. The
waybar package pulls in PulseAudio, which starts on demand (any `pactl` call
or app that wants it). Its sink volume *is* the card's `mixer vol`, not a
layer on top, and on every start it writes its saved volume back to the card,
overwriting whatever `mixer` was set to.

Use `mixer` only, and keep PulseAudio from starting:

```sh
mkdir -p ~/.config/pulse
echo 'autospawn = no' >> ~/.config/pulse/client.conf
pulseaudio -k
mixer vol=0.6
```

Apps then fall back to OSS directly. PulseAudio's log noise (no system D-Bus,
console-kit, `caps.c`) is harmless.

## II. scripts
Collection of maintained and long-forgotten scripts.

## III. themes
Per-app color palettes; picked up by the theme switcher (see above) to populate the `active-theme.*` symlinks.

## IV. nixos
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

4. `cp /etc/nixos/hardware-configuration.nix ~/syscfg/nixos-config/hosts/<host>/`

5. if *not* using LUKS, skip this step  
   add this line from `/etc/nixos/configuration.nix` to `~/syscfg/nixos-config/hosts/<host>/configuration.nix`  
   (or replace existing equivalent)
```nix
   boot.initrd.luks.devices... = "/dev/disk/by-uuid/..."
```

6. `sudo nixos-rebuild boot --flake ~/syscfg/nixos-config#<host>` and reboot

7. follow the ~5 post-setup steps in `~/org/nixos.org` (stow dotfiles, set up doom emacs and firefox, ...)

