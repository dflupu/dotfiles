local awful = require("awful")
local beautiful = require("beautiful")

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)

    if not startup and not c.size_hints.user_position
       and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c)

    local clients = #awful.client.visible(mouse.screen)

    if c.maximized_horizontal == true and
        c.maximized_vertical == true or
        clients == 1 then

        c.border_width = 0
    else
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_focus
    end
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout  = awful.layout.getname(awful.layout.get(s))

    if #clients == 1 or layout == "max" then
        clients[1].border_color = beautiful.border_normal
    else
        for i = 1, #clients do
            clients[i].border_width = beautiful.border_width
        end
    end
end)

end
