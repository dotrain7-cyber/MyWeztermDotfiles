-- Gradient palettes and utilities shared by the splash and status bar.
local wezterm = require('wezterm')
local M = {}

M.color_palettes = {
  aurora = {
    { r = 0.60, g = 0.30, b = 0.80 },
    { r = 0.80, g = 0.40, b = 0.90 },
    { r = 1.00, g = 0.50, b = 0.80 },
  },
  tokyo_night = {
    { r = 0.10, g = 0.10, b = 0.20 },
    { r = 0.20, g = 0.30, b = 0.50 },
    { r = 0.40, g = 0.50, b = 0.80 },
  },
  fire = {
    { r = 0.80, g = 0.20, b = 0.10 },
    { r = 0.90, g = 0.50, b = 0.20 },
    { r = 1.00, g = 0.90, b = 0.30 },
  },
  ocean = {
    { r = 0.00, g = 0.30, b = 0.50 },
    { r = 0.20, g = 0.60, b = 0.80 },
    { r = 0.40, g = 0.90, b = 0.90 },
  },
}

local function clamp(x)
  return math.max(0, math.min(1, tonumber(x) or 0))
end

function M.interpolate_color(a, b, amount)
  local t = clamp(amount)
  return {
    r = a.r + (b.r - a.r) * t,
    g = a.g + (b.g - a.g) * t,
    b = a.b + (b.b - a.b) * t,
  }
end

-- Loops from the last palette color back to the first without a visual jump.
function M.sample(palette_name, phase)
  local palette = M.color_palettes[palette_name] or M.color_palettes.aurora
  local pos = ((tonumber(phase) or 0) % 1) * #palette
  local index = math.floor(pos) + 1
  return M.interpolate_color(palette[index], palette[index % #palette + 1], pos % 1)
end

function M.generate_gradient(palette_name, steps)
  local result = {}
  steps = math.max(0, math.floor(tonumber(steps) or 0))
  for i = 1, steps do
    result[i] = M.sample(palette_name, steps == 1 and 0 or (i - 1) / (steps - 1))
  end
  return result
end

function M.rgb_to_ansi(r, g, b)
  return string.format('#%02x%02x%02x',
    math.floor(clamp(r) * 255 + 0.5),
    math.floor(clamp(g) * 255 + 0.5),
    math.floor(clamp(b) * 255 + 0.5))
end

function M.color_to_hex(color)
  return M.rgb_to_ansi(color.r, color.g, color.b)
end

function M.color_to_sgr(color)
  return string.format('\27[38;2;%d;%d;%dm',
    math.floor(clamp(color.r) * 255 + 0.5),
    math.floor(clamp(color.g) * 255 + 0.5),
    math.floor(clamp(color.b) * 255 + 0.5))
end

-- Chrono's %s%.3f yields Unix seconds with milliseconds.
-- Fall back to second resolution on older environments.
function M.now_seconds()
  local now = wezterm.time.now()
  return tonumber(now:format('%s%.3f')) or tonumber(now:format('%s')) or os.time()
end

function M.create_gradient_animator(palette_name, duration_seconds)
  local start = M.now_seconds()
  local duration = math.max(0.1, tonumber(duration_seconds) or 5)
  return function()
    local phase = ((M.now_seconds() - start) / duration) % 1
    return M.color_to_hex(M.sample(palette_name, phase))
  end
end

function M.pulse_color(base, target, speed, offset)
  local elapsed = M.now_seconds() - (offset or 0)
  local intensity = 0.5 + 0.5 * math.sin(elapsed * (speed or 1) * 2 * math.pi)
  -- Both input colors are RGB arrays in the range [0,1].
  return {
    base[1] + (target[1] - base[1]) * intensity,
    base[2] + (target[2] - base[2]) * intensity,
    base[3] + (target[3] - base[3]) * intensity,
  }
end

return M
