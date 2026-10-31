-- LazyVim-style WEZTERM banner: block glyphs, double-line counters, 3D extrusion.
-- Source of truth: splash/wezt-logo.txt (also printed by PowerShell and Git Bash).
local wezterm = require('wezterm')
local M = {}
local path = (wezterm.config_dir or '') .. '/splash/wezt-logo.txt'
local lines = {}
local file = io.open(path, 'r')
if file then
  for line in file:lines() do
    lines[#lines + 1] = line:gsub('\r$', '')
  end
  file:close()
end
if #lines == 0 then lines = { 'W E Z T E R M' } end
M.wezterm_logo = lines

function M.get_splash_logo(width)
  width = tonumber(width) or 95
  local logo_width = 0
  for _, line in ipairs(lines) do
    logo_width = math.max(logo_width, wezterm.column_width(line))
  end
  if width < logo_width + 2 then return { 'W E Z T E R M' } end
  return lines
end

function M.get_centered_logo(width)
  width = math.max(1, tonumber(width) or 95)
  local result = {}
  for _, line in ipairs(M.get_splash_logo(width)) do
    if wezterm.column_width(line) > width then line = 'W' end
    local pad = math.max(0, math.floor((width - wezterm.column_width(line)) / 2))
    result[#result + 1] = string.rep(' ', pad) .. line
  end
  return result
end
return M
