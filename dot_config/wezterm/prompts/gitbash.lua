-- prompts/gitbash.lua
-- Fancy prompt configuration for Git Bash
-- This goes in your ~/.bashrc or ~/.bash_profile

-- Add this to your Git Bash ~/.bashrc:
-- source ~/.config/wezterm/prompts/gitbash.lua

local prompt = {}

-- Color definitions (Tokyo Night + Vibe)
local COLORS = {
  RESET = "\033[0m",
  BLACK = "\033[30m",
  RED = "\033[31m",
  GREEN = "\033[32m",
  YELLOW = "\033[33m",
  BLUE = "\033[34m",
  MAGENTA = "\033[35m",
  CYAN = "\033[36m",
  WHITE = "\033[37m",
  
  -- Bright colors
  BRIGHT_BLUE = "\033[94m",
  BRIGHT_CYAN = "\033[96m",
  BRIGHT_MAGENTA = "\033[95m",
  BRIGHT_GREEN = "\033[92m",
  
  -- Vibe colors
  VIBE_PURPLE = "\033[38;2;122;162;247m",
  VIBE_MAGENTA = "\033[38;2;187;154;247m",
  VIBE_CYAN = "\033[38;2;125;207;255m",
  
  -- Background colors
  BG_BLUE = "\033[44m",
  BG_PURPLE = "\033[45m",
  BG_VIBE = "\033[48;2;26;27;38m",  -- Tokyo Night bg
}

-- Git status helpers
function prompt.git_branch()
  local branch = io.popen("git branch --show-current 2>/dev/null"):read("*l")
  if branch then
    return " " .. COLORS.VIBE_PURPLE .. " " .. branch .. COLORS.RESET
  end
  return ""
end

function prompt.git_status()
  local status = io.popen("git status --porcelain 2>/dev/null"):read("*a")
  if status and status ~= "" then
    if status:match("^??") then
      return COLORS.RED .. " ⓘ" .. COLORS.RESET  -- Untracked
    elseif status:match("^[MADRC]") then
      return COLORS.YELLOW .. " ⓗ" .. COLORS.RESET  -- Modified
    else
      return COLORS.GREEN .. " ✓" .. COLORS.RESET  -- Clean
    end
  end
  return ""
end

-- Directory shortening
function prompt.short_path()
  local cwd = os.getenv("PWD") or os.getenv("pwd") or ""
  local home = os.getenv("HOME") or os.getenv("USERPROFILE")
  
  if home and cwd:sub(1, #home) == home then
    cwd = "~" .. cwd:sub(#home + 1)
  end
  
  -- Replace long paths with ~
  local parts = {}
  for part in cwd:gmatch("[^/\\]+") do
    table.insert(parts, part)
  end
  
  if #parts > 3 then
    local first = parts[1]
    local last = parts[#parts]
    local second_last = parts[#parts - 1]
    return first .. "/.../" .. second_last .. "/" .. last
  end
  
  return cwd
end

-- Main prompt function
function prompt.get()
  local user = os.getenv("USER") or os.getenv("USERNAME") or "user"
  local host = os.getenv("HOSTNAME") or "localhost"
  local path = prompt.short_path()
  local branch = prompt.git_branch()
  local git_status = prompt.git_status()
  
  -- Vibe Coding styled prompt
  local p = string.format(
    "%s%s%s@%s%s %s%s%s%s%s %s%s$%s ",
    COLORS.BRIGHT_BLUE, "╭─", COLORS.RESET,
    user, host,
    COLORS.BRIGHT_CYAN, path, COLORS.RESET,
    branch, git_status,
    COLORS.VIBE_MAGENTA, "", COLORS.RESET
  )
  
  return p
end

-- Set PS1
function prompt.set()
  -- For Git Bash, we need to escape properly
  local p = prompt.get()
  -- Convert Lua escape sequences to bash escape sequences
  p = p:gsub("\033", "\\033")
  return p .. " "
end

-- Return module
return prompt
