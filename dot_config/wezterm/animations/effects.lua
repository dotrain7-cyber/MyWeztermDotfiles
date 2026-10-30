-- animations/effects.lua
-- Visual effects and animations

local wezterm = require("wezterm")
local logo = require("animations.logo")
local gradients = require("animations.gradients")

local M = {}

-- Typewriter effect for text
function M.typewriter_effect(text, delay_ms, callback)
  local chars = {}
  for i = 1, #text do
    table.insert(chars, text:sub(i, i))
  end
  
  local index = 0
  local timer
  
  timer = wezterm.time.call_after(delay_ms / 1000, function()
    index = index + 1
    if index <= #chars then
      if callback then callback(table.concat(chars, "", 1, index))
      end
      timer = wezterm.time.call_after(delay_ms / 1000, function()
        index = index + 1
        if index <= #chars then
          if callback then callback(table.concat(chars, "", 1, index))
        else
          if callback then callback(text) -- Ensure final state
          end
        end
      end)
    else
      if callback then callback(text)
      end
    end
  end)
  
  return function()
    if timer then timer:cancel() end
  end
end

-- Fade in/out effect
function M.fade_effect(start_alpha, end_alpha, duration_ms, callback)
  local start_time = wezterm.time.now()
  local timer
  
  local function update()
    local elapsed = (wezterm.time.now() - start_time) * 1000
    local progress = math.min(elapsed / duration_ms, 1.0)
    local current_alpha = start_alpha + (end_alpha - start_alpha) * progress
    
    if callback then callback(current_alpha) end
    
    if progress < 1.0 then
      timer = wezterm.time.call_after(0.016, update) -- ~60fps
    end
  end
  
  timer = wezterm.time.call_after(0, update)
  
  return function()
    if timer then timer:cancel() end
  end
end

-- Scrolling text effect
function M.scrolling_text(text, width, speed, callback)
  local full_text = text .. "    " .. text -- Loop
  local position = 0
  local timer
  
  timer = wezterm.time.call_after(0.05, function()
    position = (position + 1) % #full_text
    local visible = full_text:sub(position + 1, position + width)
    if #visible < width then
      visible = visible .. full_text:sub(1, width - #visible)
    end
    if callback then callback(visible) end
    timer = wezterm.time.call_after(speed / 1000, function()
      position = (position + 1) % #full_text
      local visible = full_text:sub(position + 1, position + width)
      if #visible < width then
        visible = visible .. full_text:sub(1, width - #visible)
      end
      if callback then callback(visible) end
    end)
  end)
  
  return function()
    if timer then timer:cancel() end
  end
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
  local gradient = gradients.generate_gradient("vibe", line_height + padding * 2)
  
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
