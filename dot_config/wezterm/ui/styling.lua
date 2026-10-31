-- Pixel dashboard: Tokyo Night colors, animated tab icon ONLY while a command runs.
local wezterm = require('wezterm')
local M = {}

M.colors = {
  background = '#101321',
  secondary = '#181c32',
  foreground = '#c0caf5',
  subdued = '#9aa5cc',
  blue = '#7aa2f7',
  cyan = '#7dcfff',
  purple = '#bb9af7',
  orange = '#ff9e64',
  green = '#9ece6a',
}

function M.apply_colors(config)
  local c = M.colors
  config.colors = {
    foreground = c.foreground,
    background = c.background,
    cursor_bg = c.orange,
    cursor_fg = c.background,
    cursor_border = c.orange,
    selection_bg = '#3b4261',
    selection_fg = '#ffffff',
    visual_bell = '#32385c',
    ansi = { '#15161e', '#f7768e', '#9ece6a', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#a9b1d6' },
    brights = { '#414868', '#f7768e', '#9ece6a', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#c0caf5' },
    tab_bar = {
      background = c.secondary,
      active_tab = { bg_color = '#2d3654', fg_color = c.foreground },
      inactive_tab = { bg_color = c.background, fg_color = c.subdued },
      inactive_tab_hover = { bg_color = '#252d49', fg_color = c.foreground },
      new_tab = { bg_color = c.secondary, fg_color = c.cyan },
      new_tab_hover = { bg_color = '#2d3654', fg_color = c.foreground },
    },
    split = '#616b95',
  }
  config.window_background_gradient = {
    orientation = { Linear = { angle = 35.0 } },
    colors = { '#0d1020', '#171b30', '#1b1830' },
    blend = 'Rgb',
    interpolation = 'Linear',
  }
end

function M.apply_tab_bar_styling(config)
  config.enable_tab_bar = true
  config.hide_tab_bar_if_only_one_tab = false
  config.use_fancy_tab_bar = false
  -- Keep tabs and shell status on top, as in the approved LazyVim-style preview.
  -- The status area is not a separately editable, pinned input line.
  config.tab_bar_at_bottom = false
  config.tab_max_width = 35
end

local function shell_info(pane)
  if not pane then return 'Terminal', '◈' end
  local ok, user_vars = pcall(function() return pane:get_user_vars() end)
  if ok and type(user_vars) == 'table' and user_vars.WEZ_SHELL and user_vars.WEZ_SHELL ~= '' then
    local name = user_vars.WEZ_SHELL
    return name, name:find('Bash') and '❖' or '⚡'
  end
  local domain_ok, domain = pcall(function() return pane:get_domain_name() end)
  if domain_ok and domain and domain ~= 'local' then
    if domain:lower():find('wsl') then return 'WSL', '🐧' end
    return domain, '✦'
  end
  local process_ok, process = pcall(function() return pane:get_foreground_process_name() end)
  process = process_ok and process and process:lower():gsub('\\', '/') or ''
  if process:find('pwsh', 1, true) then return 'PowerShell 7', '⚡' end
  if process:find('powershell', 1, true) then return 'PowerShell 5.1', '⚡' end
  if process:find('bash', 1, true) then return 'Git Bash', '❖' end
  if process:find('nvim', 1, true) then return 'Neovim', '◈' end
  return 'Terminal', '✦'
end

local function display_cwd(pane)
  if not pane then return '~' end
  local ok, loc = pcall(function() return pane:get_current_working_dir() end)
  if not ok or not loc then return '~' end
  local path = type(loc) == 'string' and loc or (loc.file_path or loc.path or '')
  path = tostring(path):gsub('^file://[^/]*', ''):gsub('%%20', ' '):gsub('\\', '/'):gsub('^/([A-Za-z]:)', '%1')
  local home = tostring(wezterm.home_dir or ''):gsub('\\', '/')
  if home ~= '' and path:sub(1, #home):lower() == home:lower() then
    local suffix = path:sub(#home + 1)
    if suffix == '' or suffix:sub(1, 1) == '/' then path = '~' .. suffix end
  end
  return wezterm.truncate_right(path, 28)
end

-- All running indicators are contained in their respective TAB; never in
-- the right status and never over the command output.  This counter advances
-- on the regular status tick and is used by the lightweight tab formatter.
local braille = { '⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏' }
M._spinner_frame = 0

local function spinner_color(frame)
  -- A subtle green -> yellow -> green pulse, with no idle animation.
  local amount = (1 - math.cos(frame * 0.29)) / 2
  local function mix(a,b) return math.floor(a + (b-a)*amount + 0.5) end
  return string.format('#%02x%02x%02x', mix(158,224), mix(206,175), mix(106,104))
end

function M.apply_tab_formatting()
  wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local c = M.colors
    local active = tab.is_active
    local bg = active and '#2d3654' or (hover and '#252d49' or c.background)
    local fg = active and c.cyan or c.subdued
    local title = tab.tab_title
    if not title or title == '' then
      title = (tab.active_pane and tab.active_pane.title) or 'Terminal'
    end
    local vars = (tab.active_pane and tab.active_pane.user_vars) or {}
    local running = vars.WEZ_RUN == 'running'
    -- The frame changes via update-status.  No synchronous process launches.
    local indicator = running and braille[(M._spinner_frame % #braille) + 1]
                         or (active and '◆' or '◇')
    local icon_color = running and spinner_color(M._spinner_frame) or fg
    title = wezterm.truncate_right(tostring(title), math.max(2, (max_width or 35) - 7))
    return {
      { Background = { Color = bg } },
      { Text = '  ' },
      { Foreground = { Color = icon_color } },
      { Text = indicator },
      { Foreground = { Color = fg } },
      { Text = ' ' .. title .. '  ' },
    }
  end)
end

function M.apply_status_bar(config)
  -- WezTerm redraws the tab bar while processing the periodic status event.
  -- 140 ms gives a readable spinner without busy-looping or idle motion.
  config.status_update_interval = 140
  wezterm.on('update-status', function(window, pane)
    M._spinner_frame = M._spinner_frame + 1
    local c = M.colors
    local shell, icon = shell_info(pane)
    local cwd = display_cwd(pane)
    window:set_left_status(wezterm.format({
      { Background = { Color = c.secondary } },
      { Foreground = { Color = c.orange } }, { Text = ' ' .. icon .. ' ' .. shell .. ' ' },
      { Foreground = { Color = c.purple } }, { Text = '│' },
      { Foreground = { Color = c.cyan } }, { Text = ' ▣ ' .. cwd .. ' ' },
    }))
    window:set_right_status(wezterm.format({
      { Background = { Color = c.secondary } },
      { Foreground = { Color = c.subdued } }, { Text = ' ' .. wezterm.strftime('%H:%M') .. ' ' },
      { Foreground = { Color = c.blue } }, { Text = 'F1 help  ' },
    }))
  end)
end

function M.apply_window_styling(config)
  local c = M.colors
  config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
  config.window_padding = { left = 12, right = 12, top = 10, bottom = 10 }
  config.window_background_opacity = 0.97
  config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.80 }
  config.window_frame = {
    font_size = 12.0,
    active_titlebar_bg = c.secondary,
    inactive_titlebar_bg = c.background,
    active_titlebar_fg = c.foreground,
    inactive_titlebar_fg = c.subdued,
    active_titlebar_border_bottom = c.blue,
    inactive_titlebar_border_bottom = c.secondary,
  }
end

function M.apply_all(config)
  M.apply_colors(config)
  M.apply_tab_bar_styling(config)
  M.apply_window_styling(config)
  M.apply_tab_formatting()
  M.apply_status_bar(config)
end

return M
