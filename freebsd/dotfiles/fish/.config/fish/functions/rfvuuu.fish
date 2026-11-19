function rfvuuu --description 'ripgrep → fzf → vim: fuzzy search + open files or quickfix list'
    set RELOAD 'reload:rg -uuu --column --color=always --smart-case {q} || :'

    set OPENER 'if test $FZF_SELECT_COUNT -eq 0
        emacsclient -t {1} +{2}  # No selection. Open the current line in Vim.
    else
        emacsclient -t +cw -q {+f}  # Build quickfix list for the selected items.
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

