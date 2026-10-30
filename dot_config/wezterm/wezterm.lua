local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- 分割したモジュールの読み込み (.config/wezterm/colors/my_colors.lua を指定)
local helper = require("colors.my_colors")

-- =====================================
-- FONT & APPEARANCE
-- =====================================
config.font = wezterm.font_with_fallback({
	"JF Dot K14",
	"JF Dot M+ 10",
	"JetBrains Mono",
	"MS Gothic",
})
config.font_size = 15.0
config.line_height = 1.1
config.cell_width = 1.05

config.color_scheme = "Tokyo Night"
config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }
config.colors = {
	cursor_bg = "#a6e3a1",
	cursor_fg = "#11111b",
	cursor_border = "#a6e3a1",
	selection_bg = "#45475a",
	selection_fg = "#cdd6f4",
}
config.default_cursor_style = "SteadyBar"

-- =====================================
-- TABS & WINDOW
-- =====================================
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 28
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.initial_cols = 120
config.initial_rows = 32

-- =====================================
-- PERFORMANCE
-- =====================================
config.max_fps = 60
config.animation_fps = 30
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.audible_bell = "Disabled"
config.automatically_reload_config = true

-- =====================================
-- KEYBINDINGS
-- =====================================
config.keys = {
	{ key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "e", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
	{
		key = "F1",
		mods = "NONE",
		action = wezterm.action.InputSelector({
			title = "日本語キー操作ヘルプ",
			choices = helper.key_help, -- 分割先から参照
			fuzzy = false,
			action = wezterm.action_callback(function(window, pane, id, label) end),
		}),
	},
}

-- =====================================
-- STATUS BAR
-- =====================================
config.status_update_interval = 1000
wezterm.on("update-status", function(window, pane)
	window:set_right_status("  " .. wezterm.strftime("%Y-%m-%d %H:%M"))
end)

return config