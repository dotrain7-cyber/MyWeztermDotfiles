-- chezmoi: dot_config/wezterm/wezterm.lua
-- Windows: start an enhanced PowerShell automatically; all other domains unchanged.
local wezterm = require('wezterm')
local config_dir = (wezterm.config_dir or ''):gsub('\\', '/')
if config_dir ~= '' then
  package.path = config_dir .. '/?.lua;' .. config_dir .. '/?/init.lua;' .. package.path
end

local styling = require('ui.styling')
local help = require('help.helper')
local act = wezterm.action
local config = wezterm.config_builder()

styling.apply_all(config)
-- Keep the original pixel font priorities and the existing Tokyo Night background.
-- Powerline wedge characters fall back to WezTerm bundled Nerd Font Symbols when needed.
config.font = wezterm.font_with_fallback({
  'JF Dot K14',
  'JF Dot M+ 10',
  'JetBrains Mono',
  'MS Gothic',
})
config.font_size = 15.0
config.line_height = 1.14
config.cell_width = 1.05
config.initial_cols = 114
config.initial_rows = 32
config.scrollback_lines = 12000
-- Returning to typing should show the active prompt, even after scrolling into history.
config.scroll_to_bottom_on_input = true
config.max_fps = 60
config.animation_fps = 30
config.audible_bell = 'Disabled'
config.automatically_reload_config = true
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 650
config.cursor_blink_ease_in = 'EaseInOut'
config.cursor_blink_ease_out = 'EaseInOut'

-- Set false to keep WezTerm's original default shell.
local AUTO_VISUAL_POWERSHELL = true
local is_windows = (wezterm.target_triple or ''):lower():find('windows') ~= nil
if is_windows and AUTO_VISUAL_POWERSHELL then
  local ok, has_pwsh = pcall(function()
    local result = wezterm.run_child_process({ 'where.exe', 'pwsh.exe' })
    return result == true
  end)
  local shell = ok and has_pwsh and 'pwsh.exe' or 'powershell.exe'
  -- PowerShell's -NoExit -Command keeps a real interactive shell after startup.
  -- Dot-sourcing (rather than -File) preserves prompt functions in that shell.
  local startup = (config_dir .. '/prompts/startup.ps1'):gsub('/', '\\')
  local command = ". '" .. startup:gsub("'", "''") .. "'"
  local args = { shell, '-NoLogo', '-NoExit', '-ExecutionPolicy', 'RemoteSigned', '-Command', command }
  config.default_prog = args
  config.launch_menu = { { label = '✦ Visual PowerShell', args = args } }
  if ok and has_pwsh then
    table.insert(config.launch_menu, { label = 'PowerShell 7 (standard)', args = { 'pwsh.exe', '-NoLogo' } })
  end
  table.insert(config.launch_menu, { label = 'Windows PowerShell (standard)', args = { 'powershell.exe', '-NoLogo' } })
end

-- No GUI-overlay splash: the shell itself prints a persistent banner before its prompt.
-- Avoids covering a ready shell and does not interfere with TUI/Neovim input.
config.keys = {
  { key = 'd', mods = 'CTRL|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'e', mods = 'CTRL|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
  { key = 'r', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },
  -- Semantic prompt navigation (PowerShell/Git Bash prompt emits OSC 133).
  { key = 'UpArrow', mods = 'ALT', action = act.ScrollToPrompt(-1) },
  { key = 'DownArrow', mods = 'ALT', action = act.ScrollToPrompt(1) },
  { key = 'End', mods = 'ALT', action = act.ScrollToBottom },
  -- F2 is reserved for PSReadLine's InlineView/ListView switch.
  { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
  { key = 'F1', mods = 'NONE', action = act.InputSelector({
    title = 'WezTerm / PowerShell / LazyVim 操作ヘルプ (Escで閉じる)',
    choices = help.key_help,
    fuzzy = true,
    action = wezterm.action_callback(function() end),
  }) },
}

-- Ctrl+R remains available for Bash reverse search and Neovim redo.
return config
