# Theme notes

`Upstream variant` names the specific variant we ported when upstream
offers more than one (e.g. gruvbox contrast levels); `—` means upstream
ships a single palette, or its dark/light split is already exposed as
separate rows here.

| Theme name                 | Upstream variant      | Upstream source                                  | Repo                                                                                         |
|----------------------------|-----------------------|--------------------------------------------------|----------------------------------------------------------------------------------------------|
| everforest-dark            | everforest-dark-hard  | sainnhe/everforest                               | https://github.com/sainnhe/everforest                                                        |
| amber                      | —                     | foxbunny/vim-amber                               | https://github.com/foxbunny/vim-amber                                                        |
| ayu-dark                   | dark                  | ayu-theme/ayu-colors (9.1.0)                     | https://github.com/ayu-theme/ayu-colors and doom-ayu-dark (doom-themes) for emacs            |
| catppuccin-frappe          | frappe                | catppuccin/catppuccin                            | https://github.com/catppuccin/catppuccin and catppuccin/emacs (MELPA) for emacs              |
| catppuccin-latte           | latte                 | catppuccin/catppuccin                            | https://github.com/catppuccin/catppuccin and catppuccin/emacs (MELPA) for emacs              |
| catppuccin-macchiato       | macchiato             | catppuccin/catppuccin                            | https://github.com/catppuccin/catppuccin and catppuccin/emacs (MELPA) for emacs              |
| catppuccin-mocha           | mocha                 | catppuccin/catppuccin                            | https://github.com/catppuccin/catppuccin and catppuccin/emacs (MELPA) for emacs              |
| doric-oak                  | —                     | protesilaos/doric-themes                         | https://github.com/protesilaos/doric-themes                                                  |
| doric-walnut               | —                     | protesilaos/doric-themes                         | https://github.com/protesilaos/doric-themes                                                  |
| doric-water                | —                     | protesilaos/doric-themes                         | https://github.com/protesilaos/doric-themes                                                  |
| dracula                    | —                     | dracula/dracula-theme                            | https://github.com/dracula/dracula-theme                                                     |
| gotham                     | —                     | whatyouhide/vim-gotham                           | https://github.com/whatyouhide/vim-gotham and https://depp.brause.cc/gotham-theme/ for emacs |
| gruvbox-dark               | gruvbox-dark-medium   | morhetz/gruvbox                                  | https://github.com/morhetz/gruvbox                                                           |
| gruvbox-light              | gruvbox-light-medium  | morhetz/gruvbox                                  | https://github.com/morhetz/gruvbox                                                           |
| laserwave                  | —                     | doomemacs/themes (doom-laserwave)                | https://github.com/doomemacs/themes                                                          |
| lumon                      | —                     | OldJobobo/omarchy-lumon-theme                    | https://github.com/OldJobobo/omarchy-lumon-theme                                             |
| matrix                     | —                     | monkeyjunglejuice/matrix-emacs-theme (Dan Dee)   | https://github.com/monkeyjunglejuice/matrix-emacs-theme                                      |
| modus-operandi             | —                     | protesilaos/modus-themes (bundled with Emacs 30) | https://github.com/protesilaos/modus-themes                                                  |
| modus-vivendi              | —                     | protesilaos/modus-themes (bundled with Emacs 30) | https://github.com/protesilaos/modus-themes                                                  |
| nord                       | —                     | nordtheme/nord                                   | https://github.com/nordtheme/nord                                                            |
| nord-light                 | —                     | doom-nord-light (doom-themes)                    | https://github.com/doomemacs/themes                                                          |
| nova                       | true-color            | doomemacs/themes (doom-nova)                     | https://github.com/doomemacs/themes/blob/master/themes/doom-nova-theme.el                    |
| osaka-jade                 | —                     | Justikun/omarchy-osaka-jade-theme                | https://github.com/Justikun/omarchy-osaka-jade-theme                                         |
| solarized-dark             | —                     | altercation/solarized                            | https://github.com/altercation/solarized                                                     |
| solarized-light            | —                     | altercation/solarized                            | https://github.com/altercation/solarized                                                     |
| solarized-selenized-black  | black                 | jan-warchol/selenized (`9a753d5`)                | https://github.com/jan-warchol/selenized and bbatsov/solarized-emacs (MELPA) for emacs       |
| solarized-selenized-dark   | dark                  | jan-warchol/selenized (`9a753d5`)                | https://github.com/jan-warchol/selenized and bbatsov/solarized-emacs (MELPA) for emacs       |
| tokyo-night                | tokyo-night-night     | tokyo-night/tokyo-night-vscode-theme             | https://github.com/tokyo-night/tokyo-night-vscode-theme                                      |
| tron-legacy                | —                     | ianpan870102/tron-legacy-emacs-theme             | https://github.com/ianpan870102/tron-legacy-emacs-theme                                      |
| vantablack                 | —                     | basecamp/omarchy (bundled)                       | https://github.com/basecamp/omarchy                                                          |
| winter-is-coming           | dark-blue             | johnpapa/vscode-winteriscoming                   | https://github.com/johnpapa/vscode-winteriscoming                                            |
| zenburn                    | default, low contrast | jnurmine/Zenburn (`9d7988a`)                     | https://github.com/jnurmine/Zenburn and doom-zenburn (doom-themes) for emacs                  |

## Selenized

Source: jan-warchol/selenized `the-values.md` (`9a753d5`), canonical sRGB
values for the dark and black variants. Emacs loads bbatsov/solarized-emacs's
`solarized-selenized-dark` and `solarized-selenized-black` unchanged
(`0f2c881`, unpinned like the other theme packages), with no face overrides
and no `solarized-*` settings. Other apps use literal palette colors, with no
computed blends. Existing solarized-dark layouts and alpha values remain;
rofi is that house layout recolored, not selenized's rofi port.

Background is bg_0, foreground fg_0. Inactive panels and unfocused borders
use bg_1 (including the tmux surface), muted text dim_0. The accent is green,
as in selenized's own i3 config; the second border color is cyan, and the
dunst frame stays blue as in solarized-dark. Yellow marks the waybar CPU
warning and notification status; urgency and the battery warning are red.
mango's maximized border is violet, since green is the focus color. Accent
and red blocks (waybar mode, battery warning; dunst critical) use bg_0 text.

foot follows selenized's ANSI table
(`manual-installation.md`): 0 = bg_1, 7 = dim_0, 8 = bg_2, 15 = fg_1, the
rest red/green/yellow/blue/magenta/cyan and their bright versions. The cursor
is fg_1.

## Zenburn

Source: [Jani Nurminen's Zenburn](https://github.com/jnurmine/Zenburn/blob/9d7988abf0d2654f837fcd288145afd5f316b70c/colors/zenburn.vim),
revision `9d7988abf0d2654f837fcd288145afd5f316b70c`. Use the default,
low-contrast variant (`zenburn_high_Contrast = 0`), without alternate options.
Emacs loads bundled `doom-zenburn` directly; other apps use literal upstream
RGB values, with no computed blends. Existing layouts and alpha values remain.

Background is #3f3f3f and foreground #dcdccc. Inactive panels use #333333;
inactive borders and muted text use #8f8f8f. Focus and selection use yellow
#f0dfaf, information cyan #8cd0d3, success green #7f9f7f, and urgency red
#cc9393. Pastel selections and critical backgrounds use #3f3f3f text.
Additional graph and gradient stops are literal upstream colors.

foot preserves upstream's exact `terminal_ansi_colors`
slot order, including its unconventional bright and magenta assignments:

```
0–7:  #1f1f1f #cc9393 #5f7f5f #ffd7a7 #8cb0d3 #8f8f8f #71d3b4 #dfe4cf
8–15: #6f6f6f #ecb3b3 #ffd7a7 #8cb0d3 #8f8f8f #71d3b4 #dfe4cf #ffcfaf
```

Terminal cursor text is #000d18 on #8faf9f, matching upstream's `Cursor`.

## Nova

Source: Doom's `doom-nova-theme.el`, using the first (true-color) value of
its palette entries. Emacs loads bundled `doom-nova` directly. App fragments
use literal palette colors, with no computed blends or lightened shades.

Background is `bg` (#3c4c55), foreground `fg` (#c5d4dd), and inactive panels
use `bg-alt` (#44545d), including tmux. Cyan (#7fc1ca) is the highlight and
selection accent; blue (#83afe5) is the secondary accent. Error, warning,
and success use red (#df8c8c), yellow (#dada93), and green (#a8ce93).
Pastel selection and critical-notification backgrounds use `base1`
(#1e272c) text. Existing layouts and alpha values are preserved.

foot uses the terminal mapping: black = `base1`
(#1e272c), bright black = `base7` (#899ba6), white = `fg` (#c5d4dd), and
bright white = `base8` (#e6eef3). Red, green, yellow, blue, magenta, and cyan
use their named palette entries; bright accent slots repeat those colors.
Other surfaces and gradients use the literal base ramp, dark-blue, orange,
and teal entries. Waybar uses cyan for the clock, timer, and active workspace,
with dark text on pastel status backgrounds.

## Catppuccin

All colors are from catppuccin/palette `palette.json` (`07d02aa`). Accent is
mauve, the second border color pink. btop is catppuccin/btop (`f437574`) with the
house transparent background. dunst takes background and text from
catppuccin/dunst (`5955cf0`), but follows the house style elsewhere: low urgency
on surface0, highlight mauve, critical on red with base text. The port marks
critical only with a peach frame, and our dunstrc draws no frame
(`frame_width = 0`). waybar and rofi use dracula's layout with Catppuccin colors
by role; on latte, info modules are blue and vpn/music teal, because sky, peach
and green are too faint on the light bar. foot uses the palette's
`ansiColors`, as catppuccin/kitty (`177d447`) does. catppuccin/foot (`99384a8`)
still repeats the normal colors as brights and swaps white and bright white.
Emacs loads the single `catppuccin` theme with `catppuccin-flavor` set, so face
overrides for `'catppuccin` hit all four flavors.

## The phosphor group

Monochrome CRTs came in three phosphor colours, and all three are in the
catalog: green P1/P31 (`matrix`), amber P3 (`amber`), white P4
(`vantablack`). Digital Equipment Corporation sold the VT220 (1983) with
a choice of exactly those three. Other phosphors existed, but none of
them were suited to text.

Dozens of phosphors were catalogued (P1, P3, P4, P11, …), each a different
compound emitting a fixed colour — you pick a chemistry, not a hue. Only
three suited continuous text. Green won on efficiency: the eye peaks near
555 nm, so a green tube looks brightest for the same beam power. White was
a hand-me-down from television, where volume made P4 cheap. Amber came
last, sold on eye comfort. The rest failed for reading — blue (P11) looks
dim and was used for exposing film, the long-persistence blends smear, red
is inefficient.

The foreground is the phosphor; the black background is just an unlit
tube, which is why matrix and vantablack both sit on #000000. `amber`
deviates with a warm near-black #140b05, inherited from vim-amber.
`vantablack` fills the white slot but its greys are dead neutral
(R=G=B throughout), so it reads as modern minimal rather than P4 paper-white.

## Removed themes

Restore the theme dir plus its Doom theme file, if the table lists one,
from the commit before the removal, e.g. for hackerman:
`git checkout 17a32dd4^ -- themes/hackerman dotfiles/doom/.config/doom/themes/ax-hackerman-theme.el`.
The Doom theme files have since moved to `themes/_emacs/`; move a restored one there.
The removal commits also dropped the theme from `scripts/bb/switch_theme.clj`
(and `weather.clj` for 17a32dd4 and 9b78cdfd) and its row from the table at
the top of this file; re-add those by hand, the switcher entry into the current
`theme-categories` map. `git show <commit>` shows what was removed, but the
older diffs no longer match today's `switch_theme.clj`.
Delete the restored `fuzzel.ini`, `hyprland.lua`, `kitty.conf` and `niri.kdl`;
fuzzel, Hyprland, niri and kitty are gone (`a823d2ce`, `ea01e5be`, `380a07d6`,
and the `retire: remove kitty, qutebrowser and vscodium` commit).
white, everforest-light and oxocarbon-light predate the mango, tmux and
wlr-which-key theme files; write those three, or
those apps keep the previous theme and the switcher reports them missing.

| Theme            | Removed    | Commit     | Doom theme file (in `dotfiles/doom/.config/doom/themes/` at removal) | Emacs theme source                      |
|------------------|------------|------------|----------------------------------------------------------------------|-----------------------------------------|
| oxocarbon        | 2026-10-27 | `774088a5` | `ax-oxocarbon-theme.el`                                              | custom                                  |
| doric-plum       | 2026-10-09 | `17a32dd4` | —                                                                    | upstream, doric-themes (`doric-plum`)   |
| flatwhite        | 2026-10-09 | `17a32dd4` | —                                                                    | doom-themes (`doom-flatwhite`)          |
| hackerman        | 2026-10-09 | `17a32dd4` | `ax-hackerman-theme.el`                                              | custom                                  |
| retro-82         | 2026-10-09 | `17a32dd4` | `ax-retro-82-theme.el`                                               | custom                                  |
| doric-marble     | 2026-10-09 | `9b78cdfd` | —                                                                    | upstream, doric-themes (`doric-marble`) |
| matte-black      | 2026-10-09 | `9b78cdfd` | `ax-matte-black-theme.el`                                            | custom                                  |
| iceberg          | 2026-09-13 | `6a5726c5` | `ax-iceberg-theme.el`                                                | custom                                  |
| wilmersdorf      | 2026-09-13 | `817eedb5` | —                                                                    | doom-themes (`doom-wilmersdorf`)        |
| white            | 2026-05-31 | `48c3d5aa` | —                                                                    | doom-themes (`doom-plain`, stand-in)    |
| everforest-light | 2026-05-31 | `2fa2b9a5` | `ax-everforest-light-theme.el`                                       | custom                                  |
| oxocarbon-light  | 2026-05-21 | `bfebbdae` | `doom-oxocarbon-light-theme.el`                                      | custom, despite the `doom-` name        |

oxocarbon-light was swapped for nord-light: `bfebbdae` turned some of its
files into nord-light's, so restoring it leaves nord-light as it is.
