if status is-login; and status is-interactive; and status test-feature query-term; and not set -q __ax_console_reexec; and string match -q '/dev/ttyv*' (tty)
    set -gx __ax_console_reexec 1
    set -l fish_bin (status fish-path)
    exec $fish_bin --features no-query-term --login
end

abbr -a startw 'dbus-run-session sway'
abbr -a up 'doas pkg upgrade'
abbr -a nf 'clear && fastfetch'

abbr -a zp 'zpool list && printf "\n---\n\n" && zpool status  && printf "\n---\n\n" && zfs list'

abbr -a cd. 'cd ~/.config'
abbr -a cds 'cd ~/sync'
abbr -a cdx 'cd ~/x'
abbr -a dl 'cd ~/Downloads'

abbr -a ga 'git add'
abbr -a gb 'git branch'
abbr -a gc 'git commit -m'
abbr -a gco 'git checkout'
abbr -a gd 'git diff'
abbr -a gin 'clear && git status && echo && git log --oneline -10 && echo && git branch && echo && tokei'
abbr -a gitinfo 'git config --get user.name && git config --get user.email'
abbr -a gr 'git restore'
abbr -a gs 'git status'
abbr -a gsw 'git show'

abbr -a sc sysctl

abbr -a hg 'history | grep -i'
abbr -a gi 'grep -i'
abbr -a rg 'rg -i'

abbr -a lt 'll -th'
abbr -a rd 'rm -rf'
abbr -a tl 'tree -L'
abbr -a vd vim -d
abbr -a pwdc 'pwd | wl-copy'
# by default, when in nnn, `e` opens a file with $VISUAL
abbr -a n "VISUAL='vim' nnn"

abbr -a rc rclone
abbr -a rcp 'rclone copy --progress'
abbr -a rct 'rclone tree --level 2'

abbr -a ssa 'sha256sum'
abbr -a ssc 'sha256sum --check --ignore-missing'

abbr -a todo 'rg -i todo --stats'

abbr -a t tmux
abbr -a tn 'tmux new-session -s'
abbr -a tls 'tmux list-sessions'
abbr -a ta 'tmux attach-session'

abbr -a ff rfv
abbr -a ffa rfvuuu

alias e "emacsclient -nw"
alias v vim
alias l 'eza -l --group-directories-first --icons'
alias lll 'eza -al --group-directories-first --icons'
alias df 'df -hT'
alias dcc 'joker $HOME/syscfg/scripts/bb/dict.cc.joke'

fish_add_path ~/.cargo/bin/
fish_add_path ~/.config/emacs/bin/
fish_add_path ~/.local/bin

export ALTERNATE_EDITOR=""
export EDITOR="emacsclient -nw"
export VISUAL="emacsclient -c"

set -g fish_greeting

if status is-interactive
    function on_exit --on-event fish_exit
        clear
    end
end

source ~/.config/fish/nnn.fish

if status is-interactive; and command -q starship
    starship init fish | source
end

# TODO: remove the __zoxide_cd_internal lines once the FreeBSD zoxide package is 0.9.9 or newer (0.9.8 can't read fish 4.x's embedded cd.fish)
if status is-interactive; and command -q zoxide
    functions --query __zoxide_cd_internal
    or functions --copy cd __zoxide_cd_internal
    zoxide init fish | source
end
