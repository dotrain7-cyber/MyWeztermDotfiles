local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- =====================================
-- FONT
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

-- =====================================
-- APPEARANCE
-- =====================================

-- config.color_scheme = "Gruvbox Dark (Gogh)"
config.color_scheme = "Tokyo Night"
-- config.color_scheme = "Tokyo Night"

-- config.window_background_opacity = 0.96

config.window_padding = {
	left = 8,
	right = 8,
	top = 6,
	bottom = 6,
}

config.colors = {
	cursor_bg = "#a6e3a1",
	cursor_fg = "#11111b",
	cursor_border = "#a6e3a1",
	selection_bg = "#45475a",
	selection_fg = "#cdd6f4",
}

-- =====================================
-- CURSOR
-- =====================================

config.default_cursor_style = "SteadyBar"

-- =====================================
-- TABS
-- =====================================

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 28

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
-- WINDOW SIZE
-- =====================================

config.initial_cols = 120
config.initial_rows = 32

-- =====================================
-- WINDOW APPEARANCE
-- =====================================
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- =====================================
-- KEYBINDINGS
-- =====================================

config.keys = {
	-- Split: side by side
	{
		key = "d",
		mods = "CTRL|SHIFT",
		action = act.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},

	-- Split: top and bottom
	{
		key = "e",
		mods = "CTRL|SHIFT",
		action = act.SplitVertical({
			domain = "CurrentPaneDomain",
		}),
	},

	-- Fullscreen
	{
		key = "Enter",
		mods = "ALT",
		action = act.ToggleFullScreen,
	},
}

-- =====================================
-- STATUS BAR
-- =====================================

config.status_update_interval = 1000

wezterm.on("update-status", function(window, pane)
	window:set_right_status("  " .. wezterm.strftime("%Y-%m-%d %H:%M"))
end)

-- ==========================================
-- Japanese Keybinding Help (F1)
-- ==========================================

local key_help = {
	-- Basic
	{ label = "[基本] i              挿入モード" },
	{ label = "[基本] a              カーソルの後ろから入力" },
	{ label = "[基本] Esc            ノーマルモードへ戻る" },
	{ label = "[基本] :w             ファイルを保存" },
	{ label = "[基本] :q             終了" },
	{ label = "[基本] :wq            保存して終了" },

	-- Cursor movement
	{ label = "[移動] h / j / k / l  左 / 下 / 上 / 右" },
	{ label = "[移動] w / b          次の単語 / 前の単語" },
	{ label = "[移動] 0 / $          行頭 / 行末" },
	{ label = "[移動] gg / G         ファイル先頭 / 末尾" },

	-- Editing
	{ label = "[編集] x              1文字削除" },
	{ label = "[編集] dd             1行削除" },
	{ label = "[編集] yy             1行コピー" },
	{ label = "[編集] p              貼り付け" },
	{ label = "[編集] u              元に戻す" },
	{ label = "[編集] Ctrl+r         やり直す" },
	{ label = "[編集] ciw            単語を置き換える" },

	-- Selection
	{ label = "[選択] v              文字単位の選択" },
	{ label = "[選択] V              行単位の選択" },
	{ label = "[選択] Ctrl+v         矩形選択（Normal）" },
	{ label = "[選択] y              選択範囲をコピー" },
	{ label = "[選択] d              選択範囲を削除" },

	-- Search
	{ label = "[検索] /文字列        ファイル内検索" },
	{ label = "[検索] n / N          次 / 前の検索結果" },
	{ label = "[検索] Space f f      LazyVimのファイル検索" },
	{ label = "[検索] Space e        ファイルツリー" },

	-- WezTerm
	{ label = "[端末] Ctrl+Shift+C   コピー" },
	{ label = "[端末] Ctrl+Shift+V   貼り付け" },
	{ label = "[端末] Ctrl+Shift+D   左右分割（独自設定）" },
	{ label = "[端末] Ctrl+Shift+E   上下分割（独自設定）" },
	{ label = "[端末] Alt+Enter      全画面切り替え" },

	-- Japanese IME
	{ label = "[日本語] i            先に挿入モードへ" },
	{ label = "[日本語] 半角/全角    日本語IMEを切り替える" },
	{ label = "[日本語] Space        日本語の変換候補を選択" },
	{ label = "[日本語] Enter        変換を確定" },
	{ label = "[日本語] Esc          確定後にNormalへ戻る" },
}

-- Preserve existing keybindings
config.keys = config.keys or {}

table.insert(config.keys, {
	key = "F1",
	mods = "NONE",
	action = wezterm.action.InputSelector({
		title = "日本語キー操作ヘルプ",
		choices = key_help,
		fuzzy = false,
		action = wezterm.action_callback(function(window, pane, id, label)
			-- Help display only: do not send keys to applications.
		end),
	}),
})

return config
