local beautiful = require("beautiful")
local awful = require("awful")
awful.rules = require("awful.rules")

awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = 0,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            keys = clientkeys,
            buttons = clientbuttons,
            size_hints_honor = false
        }
    },

    {
        rule = { instance = "plugin-container" },
        properties = { floating = true, focus = yes }
    },
    {
        rule = { instance = "osu!" },
        properties = { floating = true }
    },
    {
        rule = { instance = "polybar" },
        properties = { floating = true, focus = yes }
    },

    {
        rule = { class = "Gimp", role = "gimp-image-window" },
        properties = {
            maximized_horizontal = true,
            maximized_vertical = true }
    },
    {
        rule = { class = "chromium" },
        properties = { maximized = false } },
    {
        rule = { class = "Vivaldi-snapshot" },
        properties = { maximized = false }
    },
    {
        rule = { class = "Vivaldi-stable" },
        properties = { maximized = false }
    },
}

