# dotfiles

Stow all configs from this directory:

```sh
stow -vR --target=$HOME *
```

## After stowing on a new machine

Run the theme switcher once to create the per-app `active-theme.*` symlinks that the configs include/source:

```sh
bb ~/syscfg/scripts/bb/switch_theme.clj <theme-name>
```

Replace `<theme-name>` with whatever theme you want (e.g. `nord`, `gruvbox-dark`). This only needs to be done once.
