-- animations/__init__.lua
-- Module exports for animations package

local M = {}

-- Lazy load submodules
function M.logo()
  return require("animations.logo")
end

function M.gradients()
  return require("animations.gradients")
end

function M.effects()
  return require("animations.effects")
end

-- Direct access for convenience
M.logo = require("animations.logo")
M.gradients = require("animations.gradients")
M.effects = require("animations.effects")

return M
