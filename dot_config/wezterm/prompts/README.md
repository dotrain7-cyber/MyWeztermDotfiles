# WezTerm Fancy Prompts

This directory contains prompt configurations for different shells to match the Vibe Coding theme.

## For Git Bash (Recommended)

Add to your `~/.bashrc`:

```bash
# Load fancy Vibe prompt
source ~/.config/wezterm/prompts/gitbash.lua
PS1="$(lua -e "require('prompts.gitbash').set()')" 
```

Or create a simpler version:

```bash
# Add to ~/.bashrc
function vibe_prompt() {
    local esc="\033"
    local reset="$esc[0m"
    local blue="$esc[94m"
    local cyan="$esc[96m"
    local magenta="$esc[95m"
    local purple="$esc[38;2;122;162;247m"
    
    local user=$(whoami)
    local host=$(hostname)
    local path=$(pwd | sed "s|$HOME|~|")
    
    # Shorten path
    if [ ${#path} -gt 40 ]; then
        path="$(echo $path | rev | cut -d/ -f1-3 | rev | sed 's|.*/|.../|')"
    fi
    
    # Git info
    local branch=$(git branch --show-current 2>/dev/null)
    local git_status=""
    if [ -n "$branch" ]; then
        git_status=" $purple $branch$reset"
    fi
    
    echo "$blue╭─$reset$user@$host $cyan$path$reset$git_status$magenta $ $reset"
}

PS1="$(vibe_prompt)" 
```

## For PowerShell

Run this once to add to your profile:

```powershell
# Add to PowerShell profile
Add-Content -Path $PROFILE -Value @'
. $env:USERPROFILE\.config\wezterm\prompts\powershell.ps1
'@
```

## For cmd.exe

cmd.exe has limited prompt customization. Add to your AutoRun:

```batch
@echo off
prompt $[38;2;122;162;247m╭─$[0m$u@$c $[38;2;125;207;255m$p$[0m$[38;2;187;154;247m $ $[0m
```

## Features

- **Vibe Coding branding** - Purple/magenta/cyan color scheme
- **Shortened paths** - Truncates long directory paths
- **Git integration** - Shows branch and status
- **Cross-shell support** - Bash, PowerShell, cmd.exe
