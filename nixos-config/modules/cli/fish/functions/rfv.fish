function rfv --description 'ripgrep → fzf → emacs: fuzzy search + open files or match list'
    set RELOAD 'reload:rg --column --color=always --smart-case {q} || :'

    set OPENER 'if test $FZF_SELECT_COUNT -eq 0
        emacsclient -t +{2} {1}  # No selection. Open the current line in Emacs.
    else
        emacsclient -t {+f}  # Open the list of selected matches.
    end'

    fzf --disabled --ansi --multi \
        --bind "start:$RELOAD" \
        --bind "change:$RELOAD" \
        --bind "enter:become:$OPENER" \
        --bind "ctrl-o:execute:$OPENER" \
        --bind "alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview" \
        --delimiter : \
        --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
        --preview-window "~4,+{2}+4/3,<80(up)" \
        --query "$argv"
end

