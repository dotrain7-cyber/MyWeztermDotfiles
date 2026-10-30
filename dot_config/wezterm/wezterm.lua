-- wezterm.lua - Main configuration file
-- Modular WezTerm config with Vibe Coding theme

local wezterm = require("wezterm")

-- ============================================
-- FIX: Add config directory to Lua package path
-- This allows require("animations.logo") to work
-- ============================================
local config_dir = wezterm.config_dir
if config_dir then
  -- Normalize path for Windows (replace backslashes with forward slashes)
  config_dir = config_dir:gsub("\\", "/")
  -- Add paths for subdirectories: animations, splash, ui, prompts
  package.path = package.path .. ";" .. config_dir .. "/?.lua"
  package.path = package.path .. ";" .. config_dir .. "/?/init.lua"
  package.path = package.path .. ";" .. config_dir .. "/animations/?.lua"
  package.path = package.path .. ";" .. config_dir .. "/splash/?.lua"
  package.path = package.path .. ";" .. config_dir .. "/ui/?.lua"
  package.path = package.path .. ";" .. config_dir .. "/prompts/?.lua"
end

-- Now we can require our modules
local styling = require("ui.styling")
local logo = require("animations.logo")
local gradients = require("animations.gradients")

-- ============================================
-- MAIN CONFIG BUILDER
-- ============================================
local config = wezterm.config_builder()

-- ============================================
-- 1. UI STYLING (Colors, Tabs, Window)
-- ============================================
styling.apply_all(config)

-- ============================================
-- 2. FONT CONFIGURATION
-- ============================================
config.font = wezterm.font_with_fallback({
  "JF Dot K14",
  "JF Dot M+ 10",
  "JetBrains Mono",
  "MS Gothic",
})
config.font_size = 15.0
config.line_height = 1.1
config.cell_width = 1.05

-- ============================================
-- 3. WINDOW SETTINGS
-- ============================================
config.initial_cols = 120
config.initial_rows = 32
config.max_fps = 60
config.animation_fps = 30
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.audible_bell = "Disabled"
config.automatically_reload_config = true

-- ============================================
-- 4. SPLASH SCREEN ON STARTUP
-- ============================================
wezterm.on("gui-startup", function()
  local pane = wezterm.mux.get_active_pane()
  if not pane then return end
  
  local width, height = pane:dimensions()
  local centered_logo = logo.get_centered_logo(width)
  
  -- Build static splash content (no function to avoid errors)
  local elements = {}
  
  -- Add padding at top
  table.insert(elements, {Text = "\n\n"})
  
  -- Add logo lines with styling
  for _, line in ipairs(centered_logo) do
    table.insert(elements, {
      Attribute = {Intensity = "Bold"},
      Text = line .. "\n",
    })
  end
  
  -- Add Vibe Coding branding
  table.insert(elements, {
    Attribute = {Intensity = "Bold"},
    Foreground = {Color = "#bb9af7"},
    Text = "   ╭───────────────────────────╮\n",
  })
  table.insert(elements, {
    Attribute = {Intensity = "Bold"},
    Foreground = {Color = "#bb9af7"},
    Text = "   │      🎨  VIBE CODING  🎨     │\n",
  })
  table.insert(elements, {
    Attribute = {Intensity = "Bold"},
    Foreground = {Color = "#bb9af7"},
    Text = "   ╰───────────────────────────╯\n",
  })
  
  -- Add bottom padding
  table.insert(elements, {Text = "\n\n"})
  
  -- Create and show overlay
  local splash_overlay = wezterm.overlay.new({
    width = "100%",
    height = "100%",
    anchor = {x = "CENTER", y = "MIDDLE"},
    content = elements,
    bg_color = "#1a1b26",
    fg_color = "#c0caf5",
    timeout = 2.5,
  })
  
  if splash_overlay then
    splash_overlay:show()
  end
end)

-- ============================================
-- 5. KEYBINDINGS
-- ============================================
config.keys = {
  -- Split panes
  {
    key = "d",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "e",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  -- Fullscreen
  {
    key = "Enter",
    mods = "ALT",
    action = wezterm.action.ToggleFullScreen,
  },
  -- Reload config
  {
    key = "r",
    mods = "CTRL",
    action = wezterm.action.ReloadConfiguration,
  },
}

-- ============================================
-- 6. STATUS BAR (Animated with Vibe branding)
-- ============================================
config.status_update_interval = 1000

wezterm.on("update-status", function(window, pane)
  local colors = styling.colors
  local gradient_color = gradients.create_gradient_animator("vibe", 5)()
  
  -- Left: Working directory (safe check)
  local cwd = wezterm.cwd and wezterm.cwd() or ""
  if type(cwd) ~= "string" then cwd = "" end
  local cwd_display = wezterm.truncate_right(cwd, 40)
  
  -- Right: Time + Vibe Coding branding
  local time = wezterm.strftime("%Y-%m-%d %H:%M:%S")
  
  window:set_left_status(wezterm.format({
    {Background = {Color = colors.status_bar_bg}},
    {Foreground = {Color = colors.status_bar_fg}},
    {Text = " " .. cwd_display .. " "},
  }))
  
  window:set_right_status(wezterm.format({
    {Background = {Color = colors.status_bar_bg}},
    {Foreground = {Color = gradient_color}},
    {Text = " " .. time .. " ", " " .. "🎨 VIBE CODING" .. " "},
  }))
end)

-- ============================================
-- 7. JAPANESE KEYBINDINGS HELP (Your existing feature)
-- ============================================
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
  { label = "[選択] Ctrl+v         矩形選択" },
  { label = "[選択] y              選択範囲をコピー" },
  { label = "[選択] d              選択範囲を削除" },

  -- Search
  { label = "[検索] /文字列        ファイル内検索" },
  { label = "[検索] n / N          次 / 前の検索結果" },
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
      -- Help display only
    end),
  }),
})

-- ============================================
-- 8. FINAL TOUCHES
-- ============================================
config.default_cursor_style = "SteadyBar"
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 28

return config
