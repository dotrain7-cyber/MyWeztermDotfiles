-- splash/screen.lua
-- Startup splash screen with animations

local wezterm = require("wezterm")
local logo = require("animations.logo")
local gradients = require("animations.gradients")

local M = {}

-- State for splash screen
local splash_state = {
  visible = false,
  overlay = nil,
}

-- Create the splash screen overlay
function M.create_splash_overlay()
  if splash_state.visible then return end
  splash_state.visible = true
  
  local pane = wezterm.mux.get_active_pane()
  if not pane then return end
  
  local width, height = pane:dimensions()
  local centered_logo = logo.get_centered_logo(width)
  
  -- Build splash content
  local elements = {}
  
  -- Add padding at top
  table.insert(elements, {Text = "\n\n"})
  
  -- Add logo lines
  for _, line in ipairs(centered_logo) do
    table.insert(elements, {
      Attribute = {Intensity = "Bold"},
      Background = {Color = "#1a1b26"},
      Text = line .. "\n",
    })
  end
  
  -- Add Vibe Coding branding
  table.insert(elements, {
    Attribute = {Intensity = "Bold"},
    Foreground = {Color = "#bb9af7"},
    Text = "   ╭───────────────────────────╮\n",
  })
  table.insert(elements, {
    Attribute = {Intensity = "Bold"},
    Foreground = {Color = "#bb9af7"},
    Text = "   │      🎨  VIBE CODING  🎨     │\n",
  })
  table.insert(elements, {
    Attribute = {Intensity = "Bold"},
    Foreground = {Color = "#bb9af7"},
    Text = "   ╰───────────────────────────╯\n",
  })
  
  -- Add bottom padding
  table.insert(elements, {Text = "\n\n"})
  
  -- Create overlay
  splash_state.overlay = wezterm.overlay.new({
    width = "100%",
    height = "100%",
    anchor = {x = "CENTER", y = "MIDDLE"},
    content = elements,
    bg_color = "#1a1b26",
    fg_color = "#c0caf5",
    timeout = 2.5,
    on_close = function()
      splash_state.visible = false
      splash_state.overlay = nil
      local pane = wezterm.mux.get_active_pane()
      if pane then
        pane:activate()
      end
    end,
  })
  
  splash_state.overlay:show()
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
