local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local lain = require("lain")

local markup = lain.util.markup
local white  = beautiful.fg_focus
local gray   = beautiful.fg_normal

local created_wibox = {}
local promptbox = {}

function get_wibox()
    return created_wibox
end

function get_promptbox()
    return promptbox
end

function init(target)
    local textclock = awful.widget.textclock(
        markup.font("ubuntu mono 8", " ") ..
        markup(white, "  %H:%M ")
    )

    lain.widgets.calendar:attach(
        textclock,
        { fg = beautiful.fg_focus }
    )

    local mpdwidget = lain.widgets.mpd({
        settings = function()
            mpd_notification_preset.fg = white

            artist = mpd_now.artist .. " "
            title  = mpd_now.title  .. " "

            if mpd_now.state == "pause" then
                artist = "mpd "
                title  = "paused "
            elseif mpd_now.state == "stop" then
                artist = ""
                title  = ""
            end

            widget:set_markup(markup(gray, artist) .. markup(white, title))
        end
    })

    local fshome = lain.widgets.fs({
        partition = "/home",
        settings  = function()

            hdd = ""
            p   = ""

            if fs_now.used >= 90 then
                hdd = " Hdd "
                p   = fs_now.used .. " "
            end

            widget:set_markup(markup(gray, hdd) .. markup(white, p))
        end
    })

    local batwidget = lain.widgets.bat({
        timeout = 30,
        settings = function()
            bat_perc = bat_now.perc
            if bat_perc == '101' then bat_perc = '100' end
            bat_status = string.sub(bat_now.status, 1, 1)
            if bat_perc == "N/A" then bat_perc = "Plug" end

            battery_markup = markup(gray, " Battery ") .. bat_perc .. "%"
            if bat_status ~= 'D' then battery_markup = battery_markup .. "(" .. bat_status .. ")" end
            widget:set_markup(battery_markup)
        end
    })

    local volumewidget = lain.widgets.alsa({
        timeout = 2,
        settings = function()
            header = " Vol "
            vlevel = volume_now.level

            if volume_now.status == "off" then
                vlevel = vlevel .. "%(M) "
            else
                vlevel = vlevel .. "% "
            end

            widget:set_markup(markup(gray, header) .. vlevel)
        end
    })

    -- Separators
    local spr = wibox.widget.textbox(' ')
    local small_spr = wibox.widget.textbox('<span font="Tamsyn 4"> </span>')
    local med_spr = wibox.widget.textbox('<span font="Tamsyn 7"> </span>')

    local txtlayoutbox = {}
    local taglist = {}
    local tasklist = {}

    taglist.buttons = awful.util.table.join(
        awful.button({ }, 1, awful.tag.viewonly),
        awful.button({ modkey }, 1, awful.client.movetotag),
        awful.button({ }, 3, awful.tag.viewtoggle),
        awful.button({ modkey }, 3, awful.client.toggletag),
        awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
        awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
    )

    tasklist.buttons = awful.util.table.join(
        awful.button({ }, 1, function (c)
            if c == client.focus then
                c.minimized = true
            else
                -- Without this, the following
                -- :isvisible() makes no sense
                c.minimized = false
                if not c:isvisible() then
                    awful.tag.viewonly(c:tags()[1])
                end
                -- This will also un-minimize
                -- the client, if needed
                client.focus = c
                c:raise()
            end
        end),
        awful.button({ }, 3, function ()
            if instance then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({ width=250 })
            end
        end),
        awful.button({ }, 4, function ()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),
        awful.button({ }, 5, function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end)
    )

    function updatelayoutbox(layout, s)
        local screen = s or 1
        local txt_l = beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(screen))] or ""
        layout:set_text(txt_l)
    end

    for s = 1, screen.count() do

        promptbox[s] = awful.widget.prompt()
        txtlayoutbox[s] = wibox.widget.textbox(beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(s))])

        awful.tag.attached_connect_signal(s, "property::selected", function ()
            updatelayoutbox(txtlayoutbox[s], s)
        end)

        awful.tag.attached_connect_signal(s, "property::layout", function ()
            updatelayoutbox(txtlayoutbox[s], s)
        end)

        txtlayoutbox[s]:buttons(awful.util.table.join(
            awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
            awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
            awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
            awful.button({}, 5, function() awful.layout.inc(layouts, -1) end))
        )

        taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.noempty, taglist.buttons)
        tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.focused, tasklist.buttons, nil, nil)
        created_wibox[s] = awful.wibox({ position = "top", screen = s, height = 18, bg = beautiful.wibox_bg_normal, opacity = 0.8 })

        local left_layout = wibox.layout.fixed.horizontal()

        left_layout:add(spr)
        left_layout:add(taglist[s])
        left_layout:add(spr)
        left_layout:add(promptbox[s])

        local right_layout = wibox.layout.fixed.horizontal()

        right_layout:add(txtlayoutbox[s])
        right_layout:add(small_spr)
        right_layout:add(fshome)
        right_layout:add(med_spr)

        if target == "lpt" then
            right_layout:add(batwidget)
        end

        right_layout:add(volumewidget)

        if s == 1 then right_layout:add(wibox.widget.systray()) end
        right_layout:add(textclock)

        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_middle(tasklist[s])
        layout:set_right(right_layout)

        created_wibox[s]:set_widget(layout)
    end
end

return {
    init = init,
    get_promptbox = get_promptbox,
    get_wibox = get_wibox
}
