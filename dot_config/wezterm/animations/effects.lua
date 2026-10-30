-- animations/effects.lua
-- Visual effects and animations

local wezterm = require("wezterm")
local logo = require("animations.logo")
local gradients = require("animations.gradients")

local M = {}

-- Simple color cycling effect for status bar
function M.cycle_colors(colors, index)
  local num_colors = #colors
  local next_index = (index or 0) + 1
  if next_index > num_colors then
    next_index = 1
  end
  return colors[next_index], next_index
end

-- Get current timestamp for animations
function M.get_timestamp()
  return wezterm.time.now()
end

-- Sine wave for pulsing effects
function M.pulse_value(speed, offset)
  local now = M.get_timestamp()
  local elapsed = now - (offset or 0)
  return 0.5 + 0.5 * math.sin(elapsed * speed * 2 * math.pi)
end

-- Gradient color at a given time
function M.get_gradient_color(palette_name, speed, offset)
  local gradients = require("animations.gradients")
  local palette = gradients.color_palettes[palette_name] or gradients.color_palettes.vibe
  local num_colors = #palette
  local now = M.get_timestamp()
  local elapsed = now - (offset or 0)
  local phase = (elapsed * speed) % 1.0
  
  local segment = phase * (num_colors - 1)
  local idx1 = math.floor(segment) + 1
  local idx2 = math.min(idx1 + 1, num_colors)
  local segment_factor = segment - math.floor(segment)
  
  return gradients.interpolate_color(palette[idx1], palette[idx2], segment_factor)
end

-- Combined splash animation
function M.create_splash_animation(width, height)
  local logo_lines = logo.get_centered_logo(width)
  local line_height = #logo_lines
  local padding = math.floor((height - line_height) / 2)
  
  -- Add empty lines for centering
  local centered_logo = {}
  for i = 1, padding do
    table.insert(centered_logo, "")
  end
  for _, line in ipairs(logo_lines) do
    table.insert(centered_logo, line)
  end
  
  -- Gradient background for each line
  local gradient = require("animations.gradients").generate_gradient("vibe", line_height + padding * 2)
  
  local frames = {}
  for i = 1, #centered_logo do
    local bg_color = gradient[i] or gradient[#gradient]
    table.insert(frames, {
      text = centered_logo[i],
      bg_color = bg_color,
    })
  end
  
  return frames
end

return M
