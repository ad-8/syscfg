-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- `nwg-displays` is nice tool for this (similar to arandr on xorg)
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

-- ax: fix for pixelated emacs
-- unscale XWayland
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

-- Set programs that you use
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

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 3,

        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
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
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
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

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(menu2))


------------------------------------------------------------------------------------------------------
-- ax essential keybindings
------------------------------------------------------------------------------------------------------
-- dwm-inspired layout basics
hl.bind(mainMod .. " + J", hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + K", hl.dsp.layout("cycleprev"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("swapnext"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.layout("swapprev"))
hl.bind(mainMod .. " + H", hl.dsp.layout("mfact -0.05"))
hl.bind(mainMod .. " + L", hl.dsp.layout("mfact +0.05"))
hl.bind(mainMod .. " + Z", hl.dsp.layout("swapwithmaster master"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + I", hl.dsp.layout("addmaster"))
hl.bind(mainMod .. " + D", hl.dsp.layout("removemaster"))

-- multi-monitor keybinds
hl.bind(mainMod .. " + PERIOD", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + SHIFT + PERIOD", hl.dsp.window.move({ monitor = "+1", follow = false }))
hl.bind(mainMod .. " + SHIFT + COMMA", hl.dsp.workspace.move({ monitor = "+1", follow = false }))
-- misc
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("swaylock --color 000000"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("rofi -show recursivebrowser"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("rofi -show window"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("~/syscfg/scripts/waybar.clj toggle"))
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

-- TODO keychords
-- hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
-- TODO look into when this would be useful
-- local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
------------------------------------------------------------------------------------------------------
-- end
------------------------------------------------------------------------------------------------------


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

-- Example special workspace (scratchpad)
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

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

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

hl.window_rule({
    name  = "scratchpad",
    match = {
        -- class      = "^$",
        title      = "^hypr-scratchpad-01$",
    },
    center = true,
    float = true,
    size  = "1200 800",
    -- size = "(monitor_w*0.5) (monitor_h*0.5)",
    -- border_color = "rgba(1122ffee)",
    border_size  = 10,
    opacity      = 0.95,
})


hl.window_rule({
    name  = "anki (TODO and other floating windows?)",
    match = {
        class = "^anki$",
    },
    float = true,
    size  = "1200 800",
})

hl.window_rule({
    name  = "About Firefox",
    match = {
        title = "^About Mozilla Firefox$",
    },
    float = true,
    size  = "800 500",
})

-- TODO test scrolling layout 
hl.workspace_rule({ workspace = "5", layout = "scrolling"})
hl.bind(mainMod .. "+ M", hl.dsp.layout("focus r"))
hl.bind(mainMod .. "+ N", hl.dsp.layout("focus l"))
hl.bind(mainMod .. "+ SHIFT + M", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. "+ SHIFT + N", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "+ CONTROL + M", hl.dsp.layout("colresize +0.05"))
hl.bind(mainMod .. "+ CONTROL + N", hl.dsp.layout("colresize -0.05"))
