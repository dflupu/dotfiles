local freedesktop = require("freedesktop")
local awful = require("awful")
local beautiful = require("beautiful")

freedesktop.utils.terminal = 'roxterm'
freedesktop.utils.icon_theme = 'gnome'

local folder_awesome = {
    { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
    { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
}

local folder_programs = {}

local menu_default = freedesktop.menu.new()
local created_menu = {}

for index, item in ipairs(menu_default) do
    table.insert(folder_programs, item)
end

table.insert(created_menu, { "programs", folder_programs, beautiful.awesome_icon })
table.insert(created_menu, { "awesome", folder_awesome, beautiful.awesome_icon })

created_menu = awful.menu.new({ items = created_menu, theme = { width = 200 } })
return created_menu
