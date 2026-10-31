-- Animation functions independent of terminal IO.
local logo = require('animations.logo')
local gradients = require('animations.gradients')
local M = {}

function M.cycle_colors(colors, index)
  if #colors == 0 then return nil, 0 end
  local next_index = (index or 0) % #colors + 1
  return colors[next_index], next_index
end

function M.get_timestamp()
  return gradients.now_seconds()
end

function M.pulse_value(speed, offset)
  local elapsed = M.get_timestamp() - (offset or 0)
  return 0.5 + 0.5 * math.sin(elapsed * (speed or 1) * 2 * math.pi)
end

function M.get_gradient_color(palette_name, speed, offset)
  local phase = ((M.get_timestamp() - (offset or 0)) * (speed or 0.2)) % 1
  return gradients.sample(palette_name, phase)
end

-- Returns one frame for each visible terminal row.
-- The splash renderer applies the colors via ANSI escape sequences.
function M.create_splash_animation(width, height, phase)
  width = math.max(1, math.floor(width or 80))
  height = math.max(1, math.floor(height or 24))
  local artwork = logo.get_centered_logo(width)
  local padding = math.max(0, math.floor((height - #artwork) / 2))
  local rows = {}
  for i = 1, height do
    local line = artwork[i - padding] or ''
    rows[i] = {
      text = line,
      fg_color = gradients.sample('aurora', (phase or 0) + (i - padding) * 0.035),
    }
  end
  return rows
end

return M
