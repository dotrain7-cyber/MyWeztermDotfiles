# prompts/powershell.ps1
# Fancy prompt for PowerShell
# Add this to your PowerShell profile ($PROFILE)

function Write-VibePrompt {
    # Color definitions (ANSI escape codes for WezTerm)
    $esc = [char]27
    $reset = "$esc[0m"
    $blue = "$esc[94m"
    $cyan = "$esc[96m"
    $magenta = "$esc[95m"
    $green = "$esc[92m"
    $yellow = "$esc[93m"
    $red = "$esc[91m"
    $vibePurple = "$esc[38;2;122;162;247m"
    $vibeMagenta = "$esc[38;2;187;154;247m"
    $vibeCyan = "$esc[38;2;125;207;255m"
    
    # Get git info
    try {
        $branch = git branch --show-current 2>$null
        $status = git status --porcelain 2>$null
        $gitIcon = ""
        $gitStatus = ""
        
        if ($status) {
            if ($status -match "^\?\?") { $gitStatus = "$red ⓘ$reset" }
            elseif ($status -match "^[MADRC]") { $gitStatus = "$yellow ⓗ$reset" }
            else { $gitStatus = "$green ✓$reset" }
        }
        
        $gitInfo = if ($branch) { " $vibePurple$gitIcon $branch$reset$gitStatus" } else { "" }
    } catch {
        $gitInfo = ""
    }
    
    # Shorten path
    $path = $PWD.Path
    $home = $env:USERPROFILE
    if ($path -like "$home*") {
        $path = $path.Replace($home, "~")
    }
    
    # Truncate if too long
    if ($path.Length -gt 40) {
        $parts = $path -split '[\\/]'
        if ($parts.Count -gt 3) {
            $path = $parts[0] + "/.../" + $parts[$parts.Count-2] + "/" + $parts[$parts.Count-1]
        }
    }
    
    # Build prompt
    $prompt = "$blue╭─$reset" + "$(whoami)@$env:COMPUTERNAME " + "$cyan$path$reset" + "$gitInfo" + "$vibeMagenta$ $reset"
    
    # Return with continuation for multi-line
    "$prompt"
}

# Set the prompt
function prompt {
    Write-VibePrompt
}

# Export for use
Set-Alias -Name p -Value prompt -Scope Global
