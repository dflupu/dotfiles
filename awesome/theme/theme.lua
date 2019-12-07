
theme                               = {}
theme.dir                           = os.getenv("HOME") .. "/.config/awesome/theme"

theme.font                          = "Terminess Powerline 9"
theme.fg_normal                     = "#9E9E9E"
theme.fg_focus                      = "#EBEBFF"
theme.bg_normal                     = "#262626"
theme.bg_focus                      = "#262626"
theme.fg_urgent                     = "#000000"
theme.bg_urgent                     = "#FFFFFF"
theme.terminal_padding              = 4
theme.border_width                  = 4
theme.border_normal                 = "#7cb6c8"
theme.border_focus                  = "#ffaa9a"
theme.taglist_fg_focus              = "#EDEFFF"
theme.taglist_bg_focus              = "#262626"
theme.taglist_bg_normal             = "#FFFFFF"
theme.taglist_bg_urgent             = "#FFFFFF"
theme.menu_height                   = "16"
theme.menu_width                    = "150"
theme.wibox_bg_normal               = "#262626"
theme.termborder_width              = 10
theme.termborder_color              = "#3a3a3b"

theme.ocol                          = "<span color='" .. theme.fg_normal .. "'>"
theme.ccol                          = "</span>"
theme.tasklist_sticky               = theme.ocol .. "[S]" .. theme.ccol
theme.tasklist_ontop                = theme.ocol .. "[T]" .. theme.ccol
theme.tasklist_floating             = theme.ocol .. "[F]" .. theme.ccol
theme.tasklist_maximized_horizontal = theme.ocol .. "[M] " .. theme.ccol
theme.tasklist_maximized_vertical   = ""
theme.tasklist_disable_icon         = true
theme.tasklist_align                = "center"

theme.menu_awesome_icon             = theme.dir .. "/icons/awesome.png"
theme.menu_submenu_icon             = theme.dir .. "/icons/submenu.png"
theme.taglist_squares_sel           = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel         = theme.dir .. "/icons/square_unsel.png"
theme.vol_bg                        = theme.dir .. "/icons/vol_bg.png"

theme.layout_txt_tile               = "[t]"
theme.layout_txt_tileleft           = "[l]"
theme.layout_txt_tilebottom         = "[b]"
theme.layout_txt_tiletop            = "[tt]"
theme.layout_txt_fairv              = "[fv]"
theme.layout_txt_fairh              = "[fh]"
theme.layout_txt_spiral             = "[s]"
theme.layout_txt_dwindle            = "[d]"
theme.layout_txt_max                = "[m]"
theme.layout_txt_fullscreen         = "[F]"
theme.layout_txt_magnifier          = "[M]"
theme.layout_txt_floating           = "[*]"

-- lain related
theme.useless_gap_width             = 15
theme.layout_txt_cascade            = "[cascade]"
theme.layout_txt_cascadetile        = "[cascadetile]"
theme.layout_txt_centerwork         = "[centerwork]"
theme.layout_txt_termfair           = "[termfair]"
theme.layout_txt_centerfair         = "[centerfair]"
theme.layout_txt_uselessfair        = "[uf]"
theme.layout_txt_uselessfairh       = "[ufh]"
theme.layout_txt_uselesspiral       = "[us]"
theme.layout_txt_uselessdwindle     = "[ud]"
theme.layout_txt_uselesstile        = "[ut]"
theme.layout_txt_uselesstileleft    = "[utl]"
theme.layout_txt_uselesstiletop     = "[utt]"
theme.layout_txt_uselesstilebottom  = "[utb]"

return theme
