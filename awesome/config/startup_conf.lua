local beautiful = require("beautiful")
local naughty = require("naughty")
local awful = require("awful")

awesome.font = "gohufont 8"
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme/theme.lua")

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace-1)
    end
    awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

function init(target)

    run_once("unclutter")
    run_once("xbindkeys")
    run_once("nm-applet &")
    run_once("xfce4-clipman &")
    run_once("compton --backend glx --paint-on-overlay --glx-no-stencil --vsync opengl-swc -b -c &")
    run_once("xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'")

    if target == "lpt" then
        run_once("feh --bg-scale --randomize ~/Pictures/wallpapers")
    else
        run_once("xrandr --output DP-1 --output DP-2 --left-of VGA-1")
        run_once("feh --bg-scale ~/Pictures/wallhaven-314151.jpg ~/Pictures/wallhaven-13963.png")
    end
end

os.setlocale(os.getenv("LANG"))
return {init = init}
