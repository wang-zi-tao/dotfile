local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local util = require("widget.util")

--- Minimalist Exit Screen
--- ~~~~~~~~~~~~~~~~~~~~~~

--- Icons
local icon_font = "icomoon bold 45"
local poweroff_text_icon = " "
local reboot_text_icon = " "
local suspend_text_icon = " "
local exit_text_icon = " "
local lock_text_icon = " "

local button_bg = beautiful.background2
local button_size = dpi(120)

--- Commands
local poweroff_command = function()
    awful.spawn.with_shell("systemctl poweroff")
    awesome.emit_signal("module::exit_screen:hide")
end

local reboot_command = function()
    awful.spawn.with_shell("systemctl reboot")
    awesome.emit_signal("module::exit_screen:hide")
end

local suspend_command = function()
    awesome.emit_signal("module::exit_screen:hide")
    awesome.emit_signal("signal::lock")
    awful.spawn.with_shell("systemctl suspend")
end

local exit_command = function()
    awesome.quit()
end

local lock_command = function()
    awesome.emit_signal("module::exit_screen:hide")
    awesome.emit_signal("signal::lock")
end

local create_button = function(symbol, hover_color, text, command)
    local icon = wibox.widget({
        forced_height = button_size,
        forced_width = button_size,
        align = "center",
        valign = "center",
        font = icon_font,
        markup = util.colorize_text(symbol, beautiful.foreground1),
        widget = wibox.widget.textbox(),
    })

    local button = wibox.widget({
        {
            nil,
            icon,
            expand = "none",
            layout = wibox.layout.align.horizontal,
        },
        forced_height = button_size,
        forced_width = button_size,
        border_width = dpi(8),
        border_color = beautiful.foreground1,
        shape = util.rounded_shape(beautiful.border_radius * 2),
        bg = button_bg,
        widget = wibox.container.background,
    })

    button:buttons(gears.table.join(awful.button({}, 1, function()
        command()
    end)))

    button:connect_signal("mouse::enter", function()
        icon.markup = util.colorize_text(icon.text, hover_color)
        button.border_color = hover_color
    end)
    button:connect_signal("mouse::leave", function()
        icon.markup = util.colorize_text(icon.text, beautiful.foreground)
        button.border_color = beautiful.foreground1
    end)

    return button
end

--- Create the buttons
local poweroff = create_button(poweroff_text_icon, beautiful.xcolor1, "Poweroff", poweroff_command)
local reboot = create_button(reboot_text_icon, beautiful.xcolor2, "Reboot", reboot_command)
local suspend = create_button(suspend_text_icon, beautiful.xcolor3, "Suspend", suspend_command)
local exit = create_button(exit_text_icon, beautiful.xcolor4, "Exit", exit_command)
local lock = create_button(lock_text_icon, beautiful.xcolor5, "Lock", lock_command)

local create_exit_screen = function(s)
    s.exit_screen = wibox({
        screen = s,
        type = "splash",
        visible = false,
        ontop = true,
        bg = beautiful.transparent,
        fg = beautiful.fg_normal,
        height = s.geometry.height,
        width = s.geometry.width,
        x = s.geometry.x,
        y = s.geometry.y,
    })

    s.exit_screen:buttons(gears.table.join(
        awful.button({}, 2, function()
            awesome.emit_signal("module::exit_screen:hide")
        end),
        awful.button({}, 3, function()
            awesome.emit_signal("module::exit_screen:hide")
        end)
    ))

    s.exit_screen:setup({
        {
            resize = true,
            image = beautiful.lockscreen_wallpaper,
            valign = "center",
            halign = "center",
            forced_width = 2586,
            forced_height = 1080,
            upscale = true,
            downscale = true,
            scaling_quality = "best",
            widget = wibox.widget.imagebox,
            shape = gears.shape.rounded_bar,
        },
        {
            nil,
            {
                nil,
                {
                    {
                        poweroff,
                        reboot,
                        suspend,
                        exit,
                        lock,
                        spacing = dpi(24),
                        layout = wibox.layout.fixed.horizontal,
                    },
                    margins = 16,
                    widget = wibox.container.margin,
                },
                expand = "outside",
                layout = wibox.layout.align.horizontal,
            },
            expand = "outside",
            layout = wibox.layout.align.vertical,
        },
        layout = wibox.layout.stack,
    })
    s.exit_screen:connect_signal("mouse::leave", function()
        awesome.emit_signal("module::exit_screen:hide")
    end)
end

screen.connect_signal("request::desktop_decoration", function(s)
    create_exit_screen(s)
end)

screen.connect_signal("removed", function(s)
    create_exit_screen(s)
end)

local exit_screen_grabber = awful.keygrabber({
    auto_start = true,
    stop_event = "release",
    keypressed_callback = function(self, mod, key, command)
        if key == "s" then
            suspend_command()
        elseif key == "e" then
            exit_command()
        elseif key == "l" then
            lock_command()
        elseif key == "p" then
            poweroff_command()
        elseif key == "r" then
            reboot_command()
        elseif key == "Escape" or key == "q" or key == "x" then
            awesome.emit_signal("module::exit_screen:hide")
        end
    end,
})

awesome.connect_signal("module::exit_screen:show", function()
    for s in screen do
        s.exit_screen.visible = false
    end
    awful.screen.focused().exit_screen.visible = true
    exit_screen_grabber:start()
end)

awesome.connect_signal("module::exit_screen:hide", function()
    exit_screen_grabber:stop()
    for s in screen do
        s.exit_screen.visible = false
    end
end)
