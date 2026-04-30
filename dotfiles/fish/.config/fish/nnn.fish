# Source this file in config.fish !

# Bookmarks: example from wiki -> spaces in path are ok
export NNN_BMS=".:$HOME/.config;c:$HOME/my/code;d:$HOME/Downloads/;h:$HOME;m:$HOME/my;s:$HOME/sync"
# Plugins
set --export NNN_FIFO "/tmp/nnn.fifo"
export NNN_PLUG='P:preview-tui;p:preview-tabbed;F:fzcd;f:fzopen;'
# preview-tui uses this
export NNN_TERMINAL="foot"
