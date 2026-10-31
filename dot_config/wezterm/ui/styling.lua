-- ui/styling.lua
-- UI styling: tabs, window, status bar, colors

local wezterm = require("wezterm")
local gradients = require("animations.gradients")

local M = {}

-- Tokyo Night inspired color scheme with Vibe accents
M.colors = {
  -- Background
  background = "#1a1b26",
  background_secondary = "#16161e",
  background_tertiary = "#24283b",
  
  -- Foreground
  foreground = "#c0caf5",
  foreground_secondary = "#a9b1d6",
  
  -- Accents (Vibe purple/pink)
  accent_purple = "#7aa2f7",
  accent_magenta = "#bb9af7",
  accent_cyan = "#7dcfff",
  accent_orange = "#ff9e64",
  
  -- Cursor
  cursor_bg = "#a6e3a1",
  cursor_fg = "#11111b",
  cursor_border = "#a6e3a1",
  
  -- Selection
  selection_bg = "#45475a",
  selection_fg = "#cdd6f4",
  
  -- Tabs
  tab_bar_bg = "#16161e",
  tab_active_bg = "#24283b",
  tab_inactive_bg = "#1a1b26",
  tab_active_fg = "#c0caf5",
  tab_inactive_fg = "#565f89",
  tab_hover_bg = "#292e42",
  
  -- Status bar
  status_bar_bg = "#16161e",
  status_bar_fg = "#a9b1d6",
  
  -- Window frame colors
  window_frame_active = "#7aa2f7",
  window_frame_inactive = "#3b4261",
}

-- Apply color scheme to config
function M.apply_colors(config)
  config.color_scheme = "Tokyo Night"
  
  -- Custom colors override
  config.colors = {
    -- Background
    background = M.colors.background,
    
    -- Foreground
    foreground = M.colors.foreground,
    
    -- Cursor
    cursor_bg = M.colors.cursor_bg,
    cursor_fg = M.colors.cursor_fg,
    cursor_border = M.colors.cursor_border,
    
    -- Selection
    selection_bg = M.colors.selection_bg,
    selection_fg = M.colors.selection_fg,
    
    -- Tabs
    tab_bar = {
      background = M.colors.tab_bar_bg,
      -- Active tab
      active_tab = {
        bg_color = M.colors.tab_active_bg,
        fg_color = M.colors.tab_active_fg,
      },
      -- Inactive tabs
      inactive_tab = {
        bg_color = M.colors.tab_inactive_bg,
        fg_color = M.colors.tab_inactive_fg,
      },
      -- Inactive tab hover
      inactive_tab_hover = {
        bg_color = M.colors.tab_hover_bg,
        fg_color = M.colors.tab_active_fg,
      },
      -- New tab button
      new_tab = {
        bg_color = M.colors.tab_bar_bg,
        fg_color = M.colors.tab_inactive_fg,
      },
      -- New tab button hover
      new_tab_hover = {
        bg_color = M.colors.tab_hover_bg,
        fg_color = M.colors.tab_active_fg,
      },
    },
    
    -- Split pane
    split = "#16161e",
  }
end

-- Tab bar styling (basic settings only, no colors here)
function M.apply_tab_bar_styling(config)
  config.enable_tab_bar = true
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = false
  config.tab_max_width = 28
  config.hide_tab_bar_if_only_one_tab = false
end

-- Custom tab title formatting (using event)
function M.apply_tab_formatting()
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local colors = M.colors
    local bg_color
    local fg_color
    
    if tab.is_active then
      bg_color = colors.tab_active_bg
      fg_color = colors.tab_active_fg
    elseif hover then
      bg_color = colors.tab_hover_bg
      fg_color = colors.tab_active_fg
    else
      bg_color = colors.tab_inactive_bg
      fg_color = colors.tab_inactive_fg
    end
    
    local title = wezterm.truncate_right(tab.active_pane.title, max_width - 4)
    
    return {
      { Background = { Color = bg_color } },
      { Foreground = { Color = fg_color } },
      { Text = " " .. title .. " " },
    }
  end)
end

-- Status bar styling with animations
function M.apply_status_bar(config)
  config.status_update_interval = 1000
  
  wezterm.on("update-status", function(window, pane)
    local colors = M.colors
    local gradient_color = gradients.create_gradient_animator("vibe", 5)()
    
    -- Left status (working directory) - safe check
    local cwd = wezterm.cwd and wezterm.cwd() or ""
    if type(cwd) ~= "string" then cwd = "" end
    local cwd_display = wezterm.truncate_right(cwd, 40)
    
    -- Right: Time + Vibe Coding branding
    local time = wezterm.strftime("%Y-%m-%d %H:%M:%S")
    
    -- Use correct format: all elements must be tables with valid keys
    window:set_left_status(wezterm.format({
      { Background = { Color = colors.status_bar_bg } },
      { Foreground = { Color = colors.status_bar_fg } },
      { Text = " " .. cwd_display .. " " },
    }))
    
    window:set_right_status(wezterm.format({
      { Background = { Color = colors.status_bar_bg } },
      { Foreground = { Color = gradient_color } },
      { Text = " " .. time .. "  🎨 VIBE CODING " },
    }))
  end)
end

-- Window frame styling
function M.apply_window_styling(config)
  config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
  config.window_padding = {
    left = 8,
    right = 8,
    top = 6,
    bottom = 6,
  }
  config.window_background_opacity = 0.96
  config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
  }
  
  -- Window frame colors (separate from config.colors)
  config.window_frame = {
    active_titlebar_bg = M.colors.tab_bar_bg,
    inactive_titlebar_bg = M.colors.background_secondary,
    active_titlebar_fg = M.colors.tab_active_fg,
    inactive_titlebar_fg = M.colors.tab_inactive_fg,
    active_titlebar_border_bottom = M.colors.window_frame_active,
    inactive_titlebar_border_bottom = M.colors.window_frame_inactive,
  }
end

-- Apply all UI styling
function M.apply_all(config)
  M.apply_colors(config)
  M.apply_tab_bar_styling(config)
  M.apply_tab_formatting()
  M.apply_status_bar(config)
  M.apply_window_styling(config)
end

return M
