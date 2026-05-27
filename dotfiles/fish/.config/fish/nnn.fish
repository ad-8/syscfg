# Source this file in config.fish !

# Bookmarks: example from wiki -> spaces in path are ok
set --export NNN_BMS ".:$HOME/.config;c:$HOME/my/code;d:$HOME/Downloads/;h:$HOME;m:$HOME/my;s:$HOME/sync"

# Plugins
set --export NNN_FIFO "/tmp/nnn.fifo"

set _nnn_common 'F:fzcd;f:fzopen;g:getplugs;'
if set -q WAYLAND_DISPLAY
    set --export NNN_PLUG "p:preview-tui;P:preview-tabbed;$_nnn_common"
    set --export NNN_TERMINAL "foot"
else
    set --export NNN_PLUG "p:preview-tabbed;P:preview-tui;$_nnn_common"
end

# preview-tui img program
set --export NNN_PREVIEWIMGPROG "chafa"
