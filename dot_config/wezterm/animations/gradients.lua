-- animations/gradients.lua
-- Animated gradient color utilities

local wezterm = require("wezterm")

local M = {}

-- Color palette for gradients
M.color_palettes = {
  -- Vibe purple-pink gradient
  vibe = {
    {r = 0.6, g = 0.3, b = 0.8},   -- Purple
    {r = 0.8, g = 0.4, b = 0.9},   -- Magenta
    {r = 1.0, g = 0.5, b = 0.8},   -- Pink
  },
  -- Tokyo Night (your current theme)
  tokyo_night = {
    {r = 0.1, g = 0.1, b = 0.2},    -- Dark blue
    {r = 0.2, g = 0.3, b = 0.5},    -- Blue
    {r = 0.4, g = 0.5, b = 0.8},    -- Light blue
  },
  -- Fire gradient
  fire = {
    {r = 0.8, g = 0.2, b = 0.1},    -- Red
    {r = 0.9, g = 0.5, b = 0.2},    -- Orange
    {r = 1.0, g = 0.9, b = 0.3},    -- Yellow
  },
  -- Ocean gradient
  ocean = {
    {r = 0.0, g = 0.3, b = 0.5},     -- Deep blue
    {r = 0.2, g = 0.6, b = 0.8},     -- Teal
    {r = 0.4, g = 0.9, b = 0.9},     -- Cyan
  },
}

-- Interpolate between colors
function M.interpolate_color(c1, c2, factor)
  local r = c1.r + (c2.r - c1.r) * factor
  local g = c1.g + (c2.g - c1.g) * factor
  local b = c1.b + (c2.b - c1.b) * factor
  return {r = r, g = g, b = b}
end

-- Generate gradient colors for animation
function M.generate_gradient(palette_name, steps)
  local palette = M.color_palettes[palette_name] or M.color_palettes.vibe
  local gradient = {}
  
  local num_colors = #palette
  
  for i = 1, steps do
    local factor = (i - 1) / (steps - 1)
    local segment = factor * (num_colors - 1)
    local idx1 = math.floor(segment) + 1
    local idx2 = math.min(idx1 + 1, num_colors)
    local segment_factor = segment - math.floor(segment)
    
    local color = M.interpolate_color(palette[idx1], palette[idx2], segment_factor)
    table.insert(gradient, color)
  end
  
  return gradient
end

-- Convert RGB to ANSI color string
function M.rgb_to_ansi(r, g, b)
  return string.format("#%02x%02x%02x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

-- Animated gradient background color generator
function M.create_gradient_animator(palette_name, duration_seconds)
  local palette = M.color_palettes[palette_name] or M.color_palettes.vibe
  local start_time = os.time()
  local num_colors = #palette
  
  return function()
    local elapsed = os.time() - start_time
    local total_frames = 60 * duration_seconds  -- 60 FPS
    local frame = (elapsed * 60) % total_frames
    local factor = frame / total_frames
    
    local segment = factor * (num_colors - 1)
    local idx1 = math.floor(segment) + 1
    local idx2 = math.min(idx1 + 1, num_colors)
    local segment_factor = segment - math.floor(segment)
    
    local color = M.interpolate_color(palette[idx1], palette[idx2], segment_factor)
    return M.rgb_to_ansi(color.r, color.g, color.b)
  end
end

-- Pulsing color effect
function M.pulse_color(base_color, pulse_color, speed, time_offset)
  local now = wezterm.time.now()
  local elapsed = now - (time_offset or 0)
  local phase = (elapsed * speed) % 1.0
  
  -- Sine wave for smooth pulsing
  local intensity = 0.5 + 0.5 * math.sin(phase * 2 * math.pi)
  
  local r = base_color[1] + (pulse_color[1] - base_color[1]) * intensity
  local g = base_color[2] + (pulse_color[2] - base_color[2]) * intensity
  local b = base_color[3] + (pulse_color[3] - base_color[3]) * intensity
  
  return {r, g, b}
end

return M
