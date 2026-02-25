if status is-interactive
    # Commands to run in interactive sessions can go here
end

abbr -a cd. 'cd ~/.config'
abbr -a cdc 'cd ~/my/code'
abbr -a cdd 'cd ~/syscfg'
abbr -a cdj "cd ~/my/code/clojure"
abbr -a cdr 'cd ~/my/code/rust'
abbr -a cds 'cd ~/sync'
abbr -a cdx 'cd ~/x'
abbr -a dl 'cd ~/Downloads'

abbr -a ga 'git add'
abbr -a gb 'git branch'
abbr -a gc 'git commit -m'
abbr -a gca 'git commit --amend --no-edit'
abbr -a gcm 'git checkout main'
abbr -a gco 'git checkout'
abbr -a gd 'git diff'
abbr -a gin 'clear && git status && echo && git log --oneline -10 && echo && git branch && echo && tokei'
abbr -a gitinfo 'git config --get user.name && git config --get user.email'
abbr -a gl 'git log --oneline'
abbr -a gms 'git merge --squash'
abbr -a gr 'git restore'
abbr -a gs 'git status'
abbr -a gsw 'git show'

abbr -a sc systemctl
abbr -a r 'clear && /usr/bin/env bb --config $HOME/syscfg/bb.edn $HOME/syscfg/scripts/command_runner.clj'

if type -q code
   abbr -a c. 'code .'
else
   abbr -a c. 'codium .'
end

abbr -a gi 'grep -i'
abbr -a rg 'rg -i'

abbr -a el 'eza -l --group-directories-first --icons'
abbr -a hg 'history | grep -i'

abbr -a t. 'thunar . & disown'
abbr -a cm chezmoi
abbr -a db distrobox

abbr -a lt 'll -th'
# by default, when in nnn, `e` opens a file with $VISUAL
abbr -a n "VISUAL='emacsclient -nw' nnn"
abbr -a o. 'xdg-open .'
abbr -a pnc "protonvpn-cli ks --off && protonvpn-cli ks --permanent && protonvpn-cli c --protocol tcp --fastest" # RIP nice cli 
abbr -a rc rclone
abbr -a rd 'rm -rf'
abbr -a rl 'RUST_LOG=debug'
abbr -a ssa 'sha256sum'
abbr -a ssc 'sha256sum --check --ignore-missing'
abbr -a tl 'tree -L'
abbr -a todo 'rg -i todo --stats'
abbr -a vd vimdiff


if test "$XDG_SESSION_TYPE" = "wayland"
    abbr -a pwdc 'pwd | wl-copy'
else
    abbr -a pwdc 'pwd | xclip -selection clipboard'
end

abbr -a t tmux
abbr -a tn 'tmux new-session -s'
abbr -a tl 'tmux list-sessions'
abbr -a ta 'tmux attach-session'

abbr -a nxr nix run #e.g. 'nix run nixpkgs#hello'
abbr -a nxs nix shell
abbr -a nxd "nix develop --command fish"
abbr -a nxdu "NIXPKGS_ALLOW_UNFREE=1 nix develop --impure --command fish"
abbr -a nxfu nix flake update

abbr -a nxclean 'nh clean all --keep 3 -n'
abbr -a nxcleanb 'nh clean all --keep 3 --nogcroots -n'
abbr -a nxclean2 'nh clean all --keep-since 7d3h --nogcroots -n'

abbr -a nxgc1 'sudo nix-collect-garbage -d'
abbr -a nxgc2 'sudo nix-collect-garbage --delete-older-than 10d'
abbr -a nxgc3 'nix-store --optimise -vv'

abbr -a cg cargo
abbr -a cgb 'cargo build'
abbr -a cgc cargo check
abbr -a cgi 'cargo install --path .'
abbr -a cgr 'cargo run'
abbr -a cgt 'cargo test'
abbr -a fp flatpak
abbr -a fpl flatpak list --app
abbr -a fpu flatpak update
abbr -a pm 'pacman -S'
abbr -a pmq 'pacman -Q'
abbr -a zy zypper

# Extract the distro ID from /etc/os-release, removing any quotes
#set distro (grep -oP '^ID=\K.*' /etc/os-release | tr -d '"')
set distro (awk -F= '/^ID=/ { gsub(/["\047]/, "", $2); print $2 }' /etc/os-release)

switch $distro
    case debian ubuntu linuxmint
        abbr -a up 'sudo apt update && sudo apt upgrade'
        alias bat='batcat'
        alias fd='fdfind'
        abbr -a nf "clear && fastfetch"
    case arch
        abbr -a up 'sudo pacman -Syu'
        abbr -a nf "clear && fastfetch"
    case opensuse-tumbleweed
        abbr -a up 'sudo zypper ref && sudo zypper dup'
        abbr -a nf "clear && fastfetch --logo opensuse"
    case nixos
         abbr -a up "sudo nixos-rebuild switch --flake ~/syscfg/nixos#$hostname"
         abbr -a upb "sudo nixos-rebuild boot --flake ~/syscfg/nixos#$hostname"
         abbr -a upd "nixos-rebuild dry-run --flake ~/syscfg/nixos#$hostname"
         abbr -a up2 "NH_OS_FLAKE=~/syscfg/nixos nh os switch --ask --hostname $hostname"
         abbr -a up2b "NH_OS_FLAKE=~/syscfg/nixos nh os boot --ask --hostname $hostname"
         abbr -a nxup "NH_OS_FLAKE=~/syscfg/nixos nh os switch --ask --hostname $hostname"
         abbr -a nf "clear && fastfetch"
    case void
        abbr -a up 'sudo xbps-install -Su'
        abbr -a nf "clear && fastfetch"
    case fedora
        abbr -a up 'sudo dnf upgrade --refresh'
        abbr -a nf "clear && fastfetch"
    case freebsd
        abbr -a nf "clear && fastfetch --config neofetch"
    case '*'
        abbr -a up 'Unknown distribution. KEKW'
        abbr -a nf "clear && fastfetch"
end

switch $distro
    case arch
         #abbr -a cu "checkupdates | sed 's/->//g' | column -t"
         abbr -a cu $HOME/syscfg/scripts/bb/checkupdates.clj
    case fedora
         abbr -a cu "dnf check-update --refresh | wc -l"
    case nixos
         abbr -a cu "cd ~/syscfg/nixos/ && nix flake update && git status && printf '\n----------\n\n' && nixos-rebuild dry-run --flake ~/syscfg/nixos#$hostname"
         abbr -a lg 'nixos-rebuild list-generations | head'
    case '*'
         abbr -a cu "(checkupdate) Don't know how to on $distro"
end

abbr -a syncmoto-music "rsync -ahvP --stats '$HOME/mukke/' '/run/user/1000/gvfs/mtp:host=motorola_moto_g54_5G_ZY22HWD8XQ/Internal shared storage/Music/mukke/' --delete --omit-dir-times --no-perms --inplace --size-only --ignore-existing -n"
abbr -a syncmoto-pics "rsync -ahvP --stats '/run/user/1000/gvfs/mtp:host=motorola_moto_g54_5G_ZY22HWD8XQ/Internal shared storage/DCIM' '$HOME/sync/Moto/' -n"
abbr -a syncmoto-backup "rsync -ahvP --stats '/run/user/1000/gvfs/mtp:host=motorola_moto_g54_5G_ZY22HWD8XQ/Internal shared storage/backups' '$HOME/sync/Moto/' -n"

abbr -a sync-pixel-music "rsync -ahvP --stats ~/mukke/ /run/user/1000/gvfs/mtp:host=Google_Pixel_7a_37211JEHN10476/Internal\ shared\ storage/mukke/ --omit-dir-times --no-perms --inplace --size-only --ignore-existing -n"

abbr -a sync-pixel-backup "rsync -ahvP --stats --no-g '/run/user/1000/gvfs/mtp:host=Google_Pixel_6a_25281JEGR07582/Internal shared storage/backup' '/nas/data/backup/pixel6a' -n"

abbr -a sync-pixel-pics "rsync -ahvP --stats --no-g '/run/user/1000/gvfs/mtp:host=Google_Pixel_6a_25281JEGR07582/Internal shared storage/DCIM' '/nas/data/backup/pixel6a' -n"

# official example:                     ffmpeg                 -i input.wav -codec:a libmp3lame -qscale:a 2 output.mp3
abbr -a flac2mp3 'fd -e flac --exec ffmpeg -loglevel error -i {} -codec:a libmp3lame -qscale:a 1 {.}.mp3'

abbr -a ytdlp-split-audio "yt-dlp --format ba[ext=m4a] --split-chapters URL"

abbr -a bk bin/kamal
abbr -a br bin/rails
abbr -a dcc 'steam-run $HOME/syscfg/scripts/bb/dict.cc.clj'
abbr -a ff rfv
abbr -a ffa rfvuuu
abbr -a rcp 'rclone copy --progress'
abbr -a rct 'rclone tree --level 2'

abbr -a ifc ifconfig

fish_add_path ~/.cargo/bin/
fish_add_path ~/.config/emacs/bin/
fish_add_path ~/.local/bin

alias e "emacs -nw"
alias v vim
alias l 'eza -l --group-directories-first --icons'
alias lll 'eza -al --group-directories-first --icons'
alias x '/usr/bin/env bb ~/x/x.clj'

# --export -x is the same
set -Ux RESTIC_PASSWORD_FILE "/home/ax/.restic-std"
set -g theme_color_scheme "nord"
set -Ux PAGER less

export ALTERNATE_EDITOR=""
export EDITOR="emacsclient -nw"
export VISUAL="emacsclient -c"

export TERMINAL='alacritty'
export MAN_POSIXLY_CORRECT 1

set -Ux fish_greeting "" # disable default welcome message

function insert_timestamp --description 'Insert literal date command'
    commandline -i '$(date +%Y%m%d-%H%M%S)'
end

bind ctrl-t insert_timestamp

source ~/.config/fish/nnn.fish

starship init fish | source
zoxide init fish | source
