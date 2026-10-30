-- animations/logo.lua
-- WezTerm ASCII logo with "Vibe Coding" branding

local wezterm = require("wezterm")

local M = {}

-- WezTerm logo in blocky ASCII style
M.wezterm_logo = {
  "██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗███████╗██╗     ███████╗██████╗ ",
  "██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝██╔════╝██║     ██╔════╝██╔══██╗",
  "██║ █╗ ██║██║   ██║██████╔╝█████╔╝ █████╗  ██║     █████╗  ██████╔╝",
  "██║███╗██║██║   ██║██╔══██╗██╔═██╗ ██╔══╝  ██║     ██╔══╝  ██╔══██╗",
  "╚███╔███╔╝╚██████╔╝██║  ██║██║  ██║███████╗███████╗███████╗██║  ██║",
  " ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝",
}

-- Vibe Coding branding
M.vibe_branding = {
  "",
  "╭───────────────────────────╮",
  "│      🎨 VIBE CODING 🎨     │",
  "╰───────────────────────────╯",
  "",
}

-- Combined splash logo
function M.get_splash_logo()
  local lines = {}
  for _, line in ipairs(M.wezterm_logo) do
    table.insert(lines, line)
  end
  for _, line in ipairs(M.vibe_branding) do
    table.insert(lines, line)
  end
  return lines
end

-- Centered version for better display
function M.get_centered_logo(width)
  local lines = M.get_splash_logo()
  local centered = {}
  for _, line in ipairs(lines) do
    local padding = math.floor((width - #line) / 2)
    table.insert(centered, string.rep(" ", padding) .. line)
  end
  return centered
end

return M
