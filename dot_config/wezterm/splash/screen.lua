-- splash/screen.lua
-- Startup splash screen with animations

local wezterm = require("wezterm")
local logo = require("animations.logo")
local gradients = require("animations.gradients")
local effects = require("animations.effects")

local M = {}

-- State for splash screen
local splash_state = {
  visible = false,
  overlay = nil,
  start_time = 0,
}

-- Create the splash screen overlay
function M.create_splash_overlay()
  if splash_state.visible then return end
  splash_state.visible = true
  splash_state.start_time = wezterm.time.now()
  
  local pane = wezterm.mux.get_active_pane()
  if not pane then return end
  
  local width, height = pane:dimensions()
  
  -- Create animated splash
  local splash_lines = logo.get_splash_logo()
  local centered = logo.get_centered_logo(width)
  
  -- Generate gradient colors
  local gradient = gradients.generate_gradient("vibe", #centered + 2)
  
  -- Build splash content with gradient background
  local content = {}
  for i, line in ipairs(centered) do
    local bg_color = gradient[i + 1] or gradient[#gradient]
    table.insert(content, {
      Attribute = {Intensity = "Bold"},
      Text = line,
    })
    table.insert(content, {
      Attribute = {Reset = true},
      Text = "\n",
    })
  end
  
  -- Create overlay
  splash_state.overlay = wezterm.overlay.new({
    width = width,
    height = height,
    anchor = {x = "CENTER", y = "MIDDLE"},
    content = content,
    bg_color = "#1a1b26", -- Tokyo Night background
    fg_color = "#c0caf5", -- Text color
    timeout = 3, -- Auto-close after 3 seconds
    on_close = function()
      splash_state.visible = false
      splash_state.overlay = nil
    end,
  })
  
  -- Show overlay
  splash_state.overlay:show()
  
  -- Auto-hide after animation
  wezterm.time.call_after(3, function()
    if splash_state.overlay then
      splash_state.overlay:close()
      splash_state.visible = false
      splash_state.overlay = nil
    end
  end)
end

-- Hide splash screen manually
function M.hide_splash()
  if splash_state.overlay then
    splash_state.overlay:close()
    splash_state.visible = false
    splash_state.overlay = nil
  end
end

-- Toggle splash screen
function M.toggle_splash()
  if splash_state.visible then
    M.hide_splash()
  else
    M.create_splash_overlay()
  end
end

-- Check if splash is visible
function M.is_visible()
  return splash_state.visible
end

return M
