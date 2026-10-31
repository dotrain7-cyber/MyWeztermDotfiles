-- Splash preview data only.  The visible persistent startup logo is printed
-- directly by prompts/startup.ps1 after the shell has loaded, not injected
-- into a GUI pane (inject_output can corrupt interactive CLI/TUI redraws).
local logo = require('animations.logo')
local gradients = require('animations.gradients')
local M = {}
function M.get_preview_lines(width, phase)
  local result = {}
  for index, line in ipairs(logo.get_centered_logo(width)) do
    result[#result + 1] = { text = line, color = gradients.color_to_hex(gradients.sample('aurora', (phase or 0) + index * 0.12)) }
  end
  return result
end
return M
