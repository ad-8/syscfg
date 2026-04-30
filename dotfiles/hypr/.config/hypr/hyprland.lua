------------------
---- MONITORS ----
------------------

-- use `nwg-displays` to figure out position
hl.monitor({
    output   = "DP-1",
    mode     = "3840x2160",
    position = "0x0",
    scale    = 1.25,
})
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080",
    position = "3072x648",
    scale    = 1,
})

-- unscale XWayland (ax: fixes pixelated emacs)
hl.config({
    xwayland = {
        force_zero_scaling = true
    }
})
-- toolkit-specific scale
hl.env("GDK_SCALE", "2")
hl.env("XCURSOR_SIZE", "32")


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "footclient"
local fileManager = "thunar"
local menu        = "rofi -show drun"
local menu2       = "wmenu-run -i -l 25 -N \"0c1014\" -n \"99d1ce\" -S \"195466\" -s \"d3ebe9\""


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 
  hl.exec_cmd("blueman-applet &")
  hl.exec_cmd("dunst &")
  hl.exec_cmd("emacs --daemon &")
  hl.exec_cmd("foot --server &")
  hl.exec_cmd("hypridle &")
  hl.exec_cmd("nm-applet &")
  hl.exec_cmd("waybar &")
  hl.exec_cmd("syncthing serve --no-browser &")
  hl.exec_cmd("swaybg -i $HOME/sync/wallpapers/default.jpg &")

  hl.exec_cmd("$HOME/syscfg/scripts/bb/licht.clj hi &")

  hl.exec_cmd("[workspace special:magic silent] foot --title hypr-scratchpad-01 -e sh -c '~/x/hyprland-tmux-scratchpad.sh'")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

local gotham_black = "0c1014"
local gotham_brightblack = "11151c"
local gotham_brightgreen = "091f2e"
local gotham_brightblue = "0a3749"
local gotham_brightyellow = "245361"
local gotham_brightcyan = "599cab"
local gotham_white = "99d1ce"
local gotham_brightwhite = "d3ebe9"
local gotham_red = "c23127"
local gotham_brightred = "d26937"
local gotham_yellow = "edb443"
local gotham_brightmagenta = "888ca6"
local gotham_magenta = "4e5166"
local gotham_blue = "195466"
local gotham_cyan = "33859e"
local gotham_green = "2aa889"


hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 3,

        col = {
            -- default
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            -- inactive_border = "rgba(595959aa)",
            -- gotham
            -- active_border   = "rgb(" .. gotham_blue .. ")",
            inactive_border = "rgb(" .. gotham_black .. ")",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "master",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
    group = {
      ["col.border_active"]   = "rgb(" .. gotham_blue .. ")",
      ["col.border_inactive"] = "rgb(" .. gotham_black .. ")",

      groupbar = {
        height = 1,
        indicator_height = 30,
        text_offset = -15,
        rounding = 10,
        gaps_in = 3,
        gaps_out = 3,

        font_family         = 'Hack Nerd Font',
        font_size           = 12,

        ["col.active"]      = "rgb(" .. gotham_blue .. ")",
        ["col.inactive"]    = "rgb(" .. gotham_black .. ")",
        text_color          = "rgb(" .. gotham_white .. ")",
        text_color_inactive = "rgb(" .. gotham_white .. ")",
      }
    }
})

-- Default curves and animations
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

hl.config({
    master = {
        new_status = "master",
        new_on_top = true,
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        wrap_focus = false,
        wrap_swapcol = false,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    binds = {
        workspace_back_and_forth = true,
    },
    ecosystem = {
        no_donation_nag = true,
    },
    misc = {
        force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
        exit_window_retains_fullscreen = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "de",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        numlock_by_default = true,

        repeat_rate = 35,
        repeat_delay = 200,

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"
-- dwm-inspired basics
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(menu2))
hl.bind(mainMod .. " + J", hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + K", hl.dsp.layout("cycleprev"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("swapnext"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.layout("swapprev"))
hl.bind(mainMod .. " + H", hl.dsp.layout("mfact -0.05"))
hl.bind(mainMod .. " + L", hl.dsp.layout("mfact +0.05"))
hl.bind(mainMod .. " + RETURN", hl.dsp.layout("swapwithmaster master"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + I", hl.dsp.layout("addmaster"))
hl.bind(mainMod .. " + D", hl.dsp.layout("removemaster"))
-- tabbed windows (groups)
hl.bind(mainMod .. " + T", hl.dsp.group.toggle())
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + CONTROL + J", hl.dsp.group.next())
hl.bind(mainMod .. " + CONTROL + K", hl.dsp.group.prev())
hl.bind(mainMod .. " + ALT + J", hl.dsp.group.move_window({ forward = true}))
-- TODO conflicts with dunst history-kill
hl.bind(mainMod .. " + ALT + K", hl.dsp.group.move_window({ forward = false}))
-- TODO those bindings suck ...
hl.bind(mainMod .. " + CONTROL + SHIFT + J", hl.dsp.window.move({ into_group = 'd' }))
hl.bind(mainMod .. " + CONTROL + SHIFT + K", hl.dsp.window.move({ into_group = 'u' }))
hl.bind(mainMod .. " + CONTROL + SHIFT + H", hl.dsp.window.move({ into_group = 'l' }))
hl.bind(mainMod .. " + CONTROL + SHIFT + L", hl.dsp.window.move({ into_group = "r" }))
-- multi-monitor keybinds
hl.bind(mainMod .. " + PERIOD", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + SHIFT + PERIOD", hl.dsp.window.move({ monitor = "+1", follow = false }))
hl.bind(mainMod .. " + SHIFT + COMMA", hl.dsp.workspace.move({ monitor = "+1", follow = false }))
-- misc
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("swaylock --color 000000"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("rofi -show recursivebrowser"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("rofi -show window"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("~/syscfg/scripts/waybar.clj toggle"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("~/syscfg/scripts/waybar.clj toggle-min"))
hl.bind(mainMod .. " + TAB", hl.dsp.focus( { workspace = "previous" } ))
-- notifications
hl.bind(mainMod .. " + ALT + H", hl.dsp.exec_cmd("dunstctl history-pop"))
hl.bind(mainMod .. " + ALT + K", hl.dsp.exec_cmd("dunstctl close-all"))
hl.bind(mainMod .. " + ALT + W", hl.dsp.exec_cmd("~/syscfg/scripts/bb/weather.clj dunst"))
-- volume
hl.bind(mainMod .. " + ALT + LEFT",  hl.dsp.exec_cmd("~/syscfg/scripts/wayland.clj volume-mute"))
hl.bind(mainMod .. " + ALT + UP",    hl.dsp.exec_cmd("~/syscfg/scripts/wayland.clj volume-up"))
hl.bind(mainMod .. " + ALT + DOWN",  hl.dsp.exec_cmd("~/syscfg/scripts/wayland.clj volume-down"))
hl.bind(mainMod .. " + ALT + RIGHT", hl.dsp.exec_cmd("~/syscfg/scripts/bb/play_pause.clj"))
hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_cmd("~/syscfg/scripts/bb/play_pause.clj"))
-- TODO find free keybinds or put in submap
-- bind = $mainMod, M, exec, bb ~/x/ax_bookmarks.clj std
-- bind = $mainMod SHIFT, M, exec, bb ~/x/ax_bookmarks.clj archived

------------------------------------------------------------------------------------------
-- SUBMAP START
------------------------------------------------------------------------------------------
-- submap open
hl.bind(mainMod .. "+ O", hl.dsp.submap("open"))
hl.define_submap("open", "reset", function()
    hl.bind("B",         function() hl.exec_cmd("foot -T bluetui bluetui") end)
    hl.bind("C",         function() hl.exec_cmd("qalculate-gtk") end)
    hl.bind("E",         function() hl.exec_cmd("emacsclient -c") end)
    hl.bind("F",         function() hl.exec_cmd(fileManager) end)
    hl.bind("K",         function() hl.exec_cmd("keepassxc") end)
    hl.bind("M",         function() hl.exec_cmd("emacs --name ax-emacs-emms --eval '(ax/open-emms-layout)'") end)
    hl.bind("SHIFT + M", function() hl.exec_cmd("strawberry") end)
    hl.bind("P",         function() hl.exec_cmd("pavucontrol") end)
    hl.bind("Q",         function() hl.exec_cmd("qbittorrent") end)
    hl.bind("V",         function() hl.exec_cmd("brave") end)
    hl.bind("SHIFT + V", function() hl.exec_cmd("virt-manager") end)
    hl.bind("W",         function() hl.exec_cmd("foot -T wiremix wiremix") end)
    hl.bind("SHIFT + W", function() hl.exec_cmd("waypaper") end)
    hl.bind("X",         function() hl.exec_cmd("firefox") end)
    hl.bind("ESCAPE",    hl.dsp.submap("reset"))
end)
-- submap change
hl.bind(mainMod .. "+ C", hl.dsp.submap("change"))
hl.define_submap("change", "reset", function()
    hl.bind("L",         function() hl.exec_cmd("$HOME/syscfg/scripts/bb/licht.clj") end)
    hl.bind("W",         function() hl.exec_cmd("$HOME/syscfg/scripts/bb/set_random_wallpaper.clj") end)
    hl.bind("ESCAPE",    hl.dsp.submap("reset"))
end)
-- submap toggle
hl.bind(mainMod .. "+ G", hl.dsp.submap("toggle"))
hl.define_submap("toggle", "reset", function()
    hl.bind("B",         function() hl.exec_cmd("rfkill toggle bluetooth") end)
    hl.bind("W",         function() hl.exec_cmd("rfkill toggle wifi") end)
    hl.bind("ESCAPE",    hl.dsp.submap("reset"))
end)
-- submap X
hl.bind(mainMod .. "+ X", hl.dsp.submap("modeX"))
hl.define_submap("modeX", "reset", function()
    -- screenshot all
    hl.bind("A",         function() hl.exec_cmd("grim - | swappy -f -") end)
    -- screenshot select
    hl.bind("S",         function() hl.exec_cmd('grim -g "$(slurp)" - | swappy -f -') end)
    -- screenshot window
    hl.bind("W",         function() hl.exec_cmd("$HOME/x/hypr-screenshot-window.sh") end)
    hl.bind("ESCAPE",    hl.dsp.submap("reset"))
end)
-- universal submap reset
hl.bind(mainMod .. " + K", hl.dsp.submap("reset"), { submap_universal = true })
------------------------------------------------------------------------------------------
-- SUBMAP END
------------------------------------------------------------------------------------------

-- TODO look into when this would be useful
-- local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i, follow = false }))
end

-- special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- ax rules
hl.window_rule({
    name  = "scratchpad",
    match = {
        title = "^hypr-scratchpad-01$",
    },
    center = true,
    float = true,
    size  = "1200 800",
    border_size  = 10,
    opacity      = 0.95,
})

-- ax: named rule
hl.window_rule({
    name  = "About Firefox",
    match = {
        title = "^About Mozilla Firefox$",
    },
    float = true,
})
-- ax: anon rule
hl.window_rule({ match = { class = "^anki$" }, float = true, size = "1200 800" })

-- open programs on a certain workspace (to find out the class: `hyprctl clients`)
hl.window_rule({ match = { class = "firefox" }, workspace = "2 silent" })
hl.window_rule({ match = { class = "org.strawberrymusicplayer.strawberry" }, workspace = "6 silent" })
hl.window_rule({ match = { class = "Emacs", title = "ax-emacs-emms" }, workspace = "6 silent" })
hl.window_rule({ match = { class = "org.qbittorrent.qBittorrent" }, workspace = "7 silent" })
hl.window_rule({ match = { class = "brave-browser" }, workspace = "8 silent" })
hl.window_rule({ match = { class = ".virt-manager-wrapped" }, workspace = "8 silent" })
hl.window_rule({ match = { class = "org.keepassxc.KeePassXC" }, workspace = "9 silent" })
-- programs that should float and have a certain size
hl.window_rule({ match = { class = "qalculate-gtk" }, float = true, size = "800 600" })
hl.window_rule({ match = { class = "foot", title = "^(bluetui)|^(wiremix)$" }, float = true, size = "1024 768" })
hl.window_rule({ match = { class = "waypaper" }, float = true, size = "1024 768" })
-- more stuff that should float and keep its size
hl.window_rule({ match = { class = "Thunar", title = "File Operation Progress" }, float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })


-- TODO test scrolling layout 
hl.workspace_rule({ workspace = "5", layout = "scrolling"})
hl.bind(mainMod .. "+ M", hl.dsp.layout("focus r"))
hl.bind(mainMod .. "+ N", hl.dsp.layout("focus l"))
hl.bind(mainMod .. "+ SHIFT + M", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. "+ SHIFT + N", hl.dsp.layout("swapcol l"))
-- TODO use a submap for those, it gets too convoluted like this
hl.bind(mainMod .. "+ SHIFT + V", hl.dsp.layout("fit visible"))
hl.bind(mainMod .. "+ SHIFT + P", hl.dsp.layout("promote"))
hl.bind(mainMod .. "+ SHIFT + H", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. "+ SHIFT + L", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. "+ CONTROL + M", hl.dsp.layout("colresize +0.05"))
hl.bind(mainMod .. "+ CONTROL + N", hl.dsp.layout("colresize -0.05"))
