local awful = require("awful")
local created_menu = require("config.menu_conf")
local created_wibox = require("config.wibox_conf")
local layouts = require("config.layouts_conf")

function init(target)
    local modkey = "Mod4"
    local altkey = "Mod1"
    local terminal = "gnome-terminal"

    local browser = "vivaldi-snapshot"
    local file_browser = "dolphin"

    root.buttons(awful.util.table.join(
        awful.button({ }, 3, function () created_menu:toggle() end)
    ))

    local pc_custom_keys = {

        -- Volume
        awful.key({ }, "F11", function ()
            awful.util.spawn("amixer set Master 5%+") end),
        awful.key({ }, "F10", function ()
            awful.util.spawn("amixer set Master 5%-") end),
    }

    local lpt_custom_keys = {

        -- Volume
        awful.key({ }, "XF86AudioRaiseVolume", function ()
            awful.util.spawn("amixer set Master 5%+") end),
        awful.key({ }, "XF86AudioLowerVolume", function ()
            awful.util.spawn("amixer set Master 5%-") end),
        awful.key({ }, "XF86AudioMute", function ()
            awful.util.spawn("amixer set Master toggle") end),

        -- Brightness
        awful.key({ }, "XF86MonBrightnessDown", function ()
            awful.util.spawn("xbacklight -dec 15") end),
        awful.key({ }, "XF86MonBrightnessUp", function ()
            awful.util.spawn("xbacklight -inc 15") end),
    }

    local used_custom_keys = pc_custom_keys

    if target == "lpt" then
        used_custom_keys = lpt_custom_keys
    end

    globalkeys = awful.util.table.join(

        awful.key({ modkey }, "Left",   awful.tag.viewprev ),
        awful.key({ modkey }, "Right",  awful.tag.viewnext ),
        awful.key({ modkey }, "Escape", awful.tag.history.restore ),

        -- By direction client focus
        awful.key({ modkey }, "j",
            function()
                awful.client.focus.bydirection("down")
                if client.focus then client.focus:raise() end
        end),
        awful.key({ modkey }, "k",
            function()
                awful.client.focus.bydirection("up")
                if client.focus then client.focus:raise() end
        end),
        awful.key({ modkey }, "h",
            function()
                awful.client.focus.bydirection("left")
                if client.focus then client.focus:raise() end
        end),
        awful.key({ modkey }, "l",
            function()
                awful.client.focus.bydirection("right")
                if client.focus then client.focus:raise() end
        end),

        -- Show/Hide Wibox
        awful.key({ modkey }, "b", function ()
            local wibox = created_wibox.get_wibox()[mouse.screen.index]
            wibox.visible = not wibox.visible
        end),

        awful.key({ }, "XF86AudioMute", function ()
            awful.util.spawn("amixer sset Master toggle") end),

        -- Layout manipulation
        awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
        awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
        awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
        awful.key({ modkey,           }, "Tab",
            function ()
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end),
        awful.key({ modkey, altkey,   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
        awful.key({ modkey, altkey    }, "h",      function () awful.tag.incmwfact(-0.05)     end),
        awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
        awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
        awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1, mouse.screen)  end),
        awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1, mouse.screen)  end),
        awful.key({ modkey, "Control" }, "n",      awful.client.restore),

        -- Standard program
        awful.key({ modkey, }, "Return", function () awful.util.spawn(terminal) end),

        -- Dropdown terminal
        awful.key({ modkey, }, "z", function () drop(terminal) end),

        -- MPD control
        awful.key({ altkey, "Control" }, "Up",
            function ()
                awful.util.spawn_with_shell("mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle")
                mpdwidget.update()
            end),
        awful.key({ altkey, "Control" }, "Down",
            function ()
                awful.util.spawn_with_shell("mpc stop || ncmpcpp stop || ncmpc stop || pms stop")
                mpdwidget.update()
            end),
        awful.key({ altkey, "Control" }, "Left",
            function ()
                awful.util.spawn_with_shell("mpc prev || ncmpcpp prev || ncmpc prev || pms prev")
                mpdwidget.update()
            end),
        awful.key({ altkey, "Control" }, "Right",
            function ()
                awful.util.spawn_with_shell("mpc next || ncmpcpp next || ncmpc next || pms next")
                mpdwidget.update()
            end),

        -- User programs
        awful.key({ modkey }, "q", function () awful.util.spawn(browser) end),
        awful.key({ modkey }, "w", function () awful.util.spawn(file_browser) end),
        awful.key({ modkey }, "x", function () awful.util.spawn("xsecurelock auth_pam_x11 saver_blank") end),

        -- Prompt
        awful.key({ modkey }, "r", function ()
            created_wibox.get_promptbox()[mouse.screen.index]:run {exe_callback = spawn_here}
        end),

        -- Move and resize windows
        awful.key({ modkey, "Control" }, "s",  function () awful.client.moveresize(  0,  20,   0,   0) end),
        awful.key({ modkey, "Control" }, "w",    function () awful.client.moveresize(  0, -20,   0,   0) end),
        awful.key({ modkey, "Control" }, "a",  function () awful.client.moveresize(-20,   0,   0,   0) end),
        awful.key({ modkey, "Control" }, "d", function () awful.client.moveresize( 20,   0,   0,   0) end),
        awful.key({ modkey, "Control" }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end),
        awful.key({ modkey, "Control" }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),

        awful.key({ modkey }, ";", function () awful.screen.focus(1 + (mouse.screen.index % screen.count())) end),
        unpack(used_custom_keys)
    )

    clientkeys = awful.util.table.join(
        awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
        awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
        awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
        -- awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
        -- awful.key({ modkey, "Shift"   }, "n",      function () awful.menu.clients({ width = 250 }, { keygrabber=true }) end),
        awful.key({ modkey,           }, "n",      function (c) c.minimized = true end),
        awful.key({ modkey,           }, "m",      function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c.maximized_vertical   = not c.maximized_vertical
        end)
    )

    -- Bind all key numbers to tags.
    for i = 1, 9 do
        globalkeys = awful.util.table.join(globalkeys,
            awful.key({ modkey }, "#" .. i + 9,
                function ()
                    local screen = mouse.screen
                    local tag = awful.tag.gettags(screen)[i]
                    if tag then
                        awful.tag.viewonly(tag)
                    end
                end),
            awful.key({ modkey, "Control" }, "#" .. i + 9,
                function ()
                    local screen = mouse.screen
                    local tag = awful.tag.gettags(screen)[i]
                    if tag then
                        awful.tag.viewtoggle(tag)
                    end
                end),

            awful.key({ modkey, "Shift" }, "#" .. i + 9,
                function ()
                    local tag = awful.tag.gettags(client.focus.screen)[i]
                    if client.focus and tag then
                        awful.client.movetotag(tag)
                    end
                end),

            awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                function ()
                    local tag = awful.tag.gettags(client.focus.screen)[i]
                    if client.focus and tag then
                        awful.client.toggletag(tag)
                    end
                end),
            awful.key({ modkey }, "/", function() cheeky.util.switcher() end)

        )
    end

    clientbuttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ modkey }, 1, awful.mouse.client.move),
        awful.button({ modkey }, 3, awful.mouse.client.resize)
    )

    root.keys(globalkeys)
end

function spawn_here(cmd)
    awful.spawn(cmd, {
        tag = mouse.screen.selected_tag,
        screen = mouse.screen.index,
    })
end

return {init = init}
