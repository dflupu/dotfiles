local lain  = require("lain")
local awful = require("awful")

lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol    = 1

local layouts = {
    lain.layout.uselesstile.left,
    lain.layout.uselesstile,
    lain.layout.uselesstile.bottom,
    awful.layout.suit.floating,
    lain.layout.uselessfair.horizontal
}

tags = {
    names = { "1", "2", "3", "4", "5", "6", "7", "8", "9"},
    layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
}

for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end

return layouts
