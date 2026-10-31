# Pixel Pencil prompt for PowerShell 5.1 / 7.
# This file is dot-sourced by prompts/startup.ps1, not executed in a child process.
if ($global:WezVisualPromptInitialized) { return }
$global:WezVisualPromptInitialized = $true

$configHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME '.config' }
$env:STARSHIP_CONFIG = Join-Path $configHome 'starship.toml'

# Identify the shell in WezTerm's persistent status bar and tab title.
try {
    $shellName = if ($PSVersionTable.PSVersion.Major -ge 7) { 'PowerShell 7' } else { 'PowerShell 5.1' }
    $esc = [char]27
    $bel = [char]7
    $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($shellName))
    [Console]::Write("${esc}]1337;SetUserVar=WEZ_SHELL=${encoded}${bel}")
    [Console]::Write("${esc}]0;${shellName} | WezTerm${bel}")
} catch {}

# Shell -> WezTerm execution state. Values are base64 for the OSC 1337 protocol.
# They are sent to the *pane*, not drawn into the scrollback.
function global:Send-WezPaneVar {
    param([ValidatePattern('^[A-Z_]+$')][string] $Name, [string] $Value)
    if (-not $env:WEZTERM_PANE) { return }
    try {
        $esc = [char]27
        $bel = [char]7
        $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Value))
        [Console]::Write("${esc}]1337;SetUserVar=${Name}=${b64}${bel}")
    } catch {}
}

# V10: WezTerm draws a small spinner only in the active tab after an Enter
# is accepted.  Commands run in the ORIGINAL PowerShell process (no Start-Job).
# PSReadLine 2.0 / PowerShell 5.1: do not call Get-PSReadLineKeyHandler -Chord.
$global:WezEnterHookStatus = 'not installed'
$global:WezVisualTransientEnabled = ($env:WEZTERM_TRANSIENT_PROMPT -ne '0')
$global:WezRenderTransient = $false
$global:WezPencilPromptVisibleCells = 0

# This shell is started inside WezTerm, whose output protocol is UTF-8.
# Windows PowerShell 5.1 may otherwise emit question marks for box-drawing text.
# Do not overwrite $OutputEncoding (pipeline encoding for native programs).
try {
    if ([Console]::OutputEncoding.CodePage -ne 65001) {
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    }
} catch { }

# One-line OUTLINE of the exact active path segments.  No solid backgrounds.
# "Box" uses light vertical sides + hollow Powerline wedges; ASCII fallback
# uses plain | and > if Windows PS 5.1/font displays question marks.
$global:WezTransientStyle = if ($env:WEZTERM_TRANSIENT_STYLE -eq 'ASCII') { 'ASCII' } else { 'Box' }
$global:WezLastPromptSegments = @()
$global:WezLastPromptColors = @()
function global:Set-WezTransientStyle {
    param([ValidateSet('Box','ASCII')][string]$Style = 'Box')
    $global:WezTransientStyle = $Style
    $env:WEZTERM_TRANSIENT_STYLE = $Style
    Write-Host ('Outline prompt: ' + $Style + ' (takes effect on next Enter)')
}

function global:Get-WezBoundEnterHandler {
    $cmd = Get-Command Get-PSReadLineKeyHandler -ErrorAction Stop
    if ($cmd.Parameters.ContainsKey('Chord')) {
        Get-PSReadLineKeyHandler -Chord 'Enter' -ErrorAction Stop | Select-Object -First 1
        return
    }
    # PSReadLine 2.0.0 bundled with Windows PowerShell 5.1.
    Get-PSReadLineKeyHandler -Bound -ErrorAction Stop |
        Where-Object { [string]$_.Key -eq 'Enter' } | Select-Object -First 1
}

function global:Get-WezAnimationDiagnostic {
    $handler = $null
    try { $handler = Get-WezBoundEnterHandler } catch {}
    $mode = 'unknown'
    try { $mode = [string](Get-PSReadLineOption).EditMode } catch {}
    $psrlVersion = 'not loaded'
    try {
        $module = Get-Module PSReadLine
        if ($module) { $psrlVersion = $module.Version.ToString() }
    } catch {}
    [pscustomobject]@{
        Shell                  = $PSVersionTable.PSVersion.ToString()
        PSReadLineVersion      = $psrlVersion
        EnterFunction          = $(if ($handler) { [string]$handler.Function } else { 'unknown' })
        EnterHookStatus        = $global:WezEnterHookStatus
        TransientEnabled       = $global:WezVisualTransientEnabled
        StatusBarAnimation     = 'Tab spinner only (when WEZ_RUN=running)'
        ExecutionMode          = 'Native, no job / subprocess wrapper'
        SpinnerTest            = 'Test-WezTabSpinner -Seconds 7'
        WezTermPane            = $env:WEZTERM_PANE
        OutputRedirected       = [Console]::IsOutputRedirected
        ConsoleEncoding        = [Console]::OutputEncoding.WebName
        TransientStyle         = $global:WezTransientStyle
        StarshipOverride       = ($env:WEZTERM_USE_STARSHIP -eq '1')
    }
}

# Force the TAB spinner using the normal PowerShell process; no output rewriting.
# This tests the WezTerm renderer independently of the Enter-key hook.
function global:Test-WezTabSpinner {
    param([ValidateRange(1,30)][int]$Seconds = 7)
    if (-not $env:WEZTERM_PANE) {
        Write-Warning 'Not inside a WezTerm pane: tab animation cannot be seen.'
        return
    }
    Send-WezPaneVar -Name WEZ_RUN -Value running
    try { Start-Sleep -Seconds $Seconds }
    finally { Send-WezPaneVar -Name WEZ_RUN -Value idle }
}
function global:Test-WezAnimation {
    param([ValidateRange(1,30)][int]$Seconds = 7, [string]$Mode = 'Worm')
    Test-WezTabSpinner -Seconds $Seconds
}

# Highlight commands as they are typed. Optional predictions require a newer PSReadLine.
try {
    if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
        $esc = [char]27
        Set-PSReadLineOption -Colors @{
            Command   = "${esc}[38;2;125;207;255m"
            Parameter = "${esc}[38;2;187;154;247m"
            String    = "${esc}[38;2;158;206;106m"
            Number    = "${esc}[38;2;255;158;100m"
            Variable  = "${esc}[38;2;224;175;104m"
            Operator  = "${esc}[38;2;247;118;142m"
            Keyword   = "${esc}[38;2;187;154;247m"
            Type      = "${esc}[38;2;122;162;247m"
            Comment   = "${esc}[38;2;86;95;137m"
            Error     = "${esc}[38;2;247;118;142m"
            Emphasis  = "${esc}[38;2;224;175;104m"
        } -ErrorAction SilentlyContinue
        # Historical suggestions require PSReadLine 2.1+; plugins require PS 7.2+.
        # Only enable options the installed version understands.
        try {
            $predictionSource = if ($PSVersionTable.PSVersion.Major -ge 7 -and
                $PSVersionTable.PSVersion.Minor -ge 2) { 'HistoryAndPlugin' } else { 'History' }
            Set-PSReadLineOption -PredictionSource $predictionSource -ErrorAction Stop
        } catch {
            try { Set-PSReadLineOption -PredictionSource History -ErrorAction Stop } catch {}
        }
        try { Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction Stop } catch {}
        try { Set-PSReadLineKeyHandler -Chord 'Ctrl+Spacebar' -Function MenuComplete -ErrorAction Stop } catch {}

        # A single PSReadLine handler manages execution animation AND transient prompt.
        # Never alter an existing custom Enter binding or Vi mode. An unbound Enter
        # is safe to set on a freshly imported PSReadLine session.
        if ($env:WEZTERM_PANE -and $env:WEZTERM_USE_STARSHIP -ne '1') {
            try {
                $editMode = (Get-PSReadLineOption).EditMode
                $handler = Get-WezBoundEnterHandler
                if ($editMode -eq 'Vi') {
                    $global:WezEnterHookStatus = 'skipped (Vi mode)'
                } elseif ($handler -and $handler.Function -ne 'AcceptLine') {
                    $name = if ($handler) { [string] $handler.Function } else { 'unbound' }
                    $global:WezEnterHookStatus = "skipped (custom Enter: $name)"
                } else {
                    Set-PSReadLineKeyHandler -Chord Enter -BriefDescription 'WezTerm native run + outline' -ScriptBlock {
                        $line = ''
                        $cursor = 0
                        $complete = $false
                        $oneLine = $false
                        try {
                            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(
                                [ref]$line, [ref]$cursor)
                            $oneLine = -not ($line.Contains("`n") -or $line.Contains("`r"))
                            if ([string]::IsNullOrWhiteSpace($line)) {
                                # Empty Enter still converts the PREVIOUS active pencil
                                # into its outlined version, but does not start RUNNING.
                                $complete = $true
                            } else {
                                $tokens = $null
                                $parseErrors = $null
                                [void][System.Management.Automation.Language.Parser]::ParseInput(
                                    $line, [ref]$tokens, [ref]$parseErrors)
                                $complete = (@($parseErrors | Where-Object { $_.IncompleteInput }).Count -eq 0)
                            }
                        } catch {}
                        if ($complete) {
                            if ($global:WezVisualTransientEnabled -and $oneLine) {
                                # Only redraw when the prompt + input fits on one
                                # visible row; wrapped/multiline commands keep the
                                # original prompt to avoid damaged scrollback.
                                try {
                                    $cols = [Console]::WindowWidth
                                    if ($cols -gt 0 -and
                                        ($global:WezPencilPromptVisibleCells + $line.Length) -lt ($cols - 2)) {
                                        $global:WezRenderTransient = $true
                                        try { [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt() }
                                        finally { $global:WezRenderTransient = $false }
                                    }
                                } catch { $global:WezRenderTransient = $false }
                            }
                            try { [Console]::Write("$([char]27)]133;C$([char]7)") } catch {}
                            # A real command runs normally, IN THIS SHELL.  If
                            # whitespace-only, show outline but keep tab idle.
                            if (-not [string]::IsNullOrWhiteSpace($line)) {
                                Send-WezPaneVar -Name WEZ_RUN -Value running
                            }
                        }
                        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
                    } -ErrorAction Stop
                    $global:WezEnterHookStatus = 'installed'
                }
            } catch {
                $global:WezEnterHookStatus = 'error: ' + $_.Exception.Message
            }
        } else {
            $global:WezEnterHookStatus = 'skipped (not in WezTerm or Starship mode)'
        }
    }
} catch {}

# Optional escape hatch for users who prefer Starship's generic Powerline prompt.
# The default is the native prompt because it can color every directory level separately.
if ($env:WEZTERM_USE_STARSHIP -eq '1' -and (Get-Command starship -ErrorAction SilentlyContinue)) {
    try {
        Invoke-Expression (& starship init powershell)
        return
    } catch {}
}

function global:Get-WezPencilSegments {
    param([string] $LocationPath)
    $normalized = $LocationPath -replace '\\', '/'
    $homePath = ($HOME -replace '\\', '/').TrimEnd([char]'/')
    if ($homePath -and $normalized.Length -ge $homePath.Length -and
        $normalized.Substring(0, $homePath.Length).Equals($homePath, [StringComparison]::OrdinalIgnoreCase)) {
        $remaining = $normalized.Substring($homePath.Length)
        if ($remaining -eq '' -or $remaining.StartsWith('/')) { $normalized = '~' + $remaining }
    }

    $pieces = @($normalized -split '/' | Where-Object { $_ -ne '' })
    if ($pieces.Count -eq 0) { $pieces = @('~') }
    if ($pieces.Count -gt 6) {
        $pieces = @($pieces[0], '…') + @($pieces | Select-Object -Last 4)
    }
    foreach ($piece in $pieces) {
        $label = [string] $piece
        if ($label.Length -gt 25) { $label = $label.Substring(0, 12) + '…' + $label.Substring($label.Length - 10) }
        $label
    }
}

# All palettes use the same Classic Chevron A geometry; colors alone are switchable.
# Changing the palette never changes the WezTerm background or the startup logo.
$global:WezPencilPalettes = @{
    Classic = @('187;154;247', '125;207;255', '224;175;104', '158;206;106', '122;162;247')
    Sunset  = @('247;118;142', '255;158;100', '224;175;104', '187;154;247', '125;207;255')
    Ocean   = @('122;162;247', '125;207;255', '158;206;106', '187;154;247', '224;175;104')
}
$global:WezPencilPalette = 'Classic'
if ($env:WEZTERM_PROMPT_PALETTE -in @('Classic', 'Sunset', 'Ocean')) {
    $global:WezPencilPalette = $env:WEZTERM_PROMPT_PALETTE
}
function global:Set-WezPencilPalette {
    param([ValidateSet('Classic', 'Sunset', 'Ocean')][string] $Name = 'Classic')
    $global:WezPencilPalette = $Name
    $env:WEZTERM_PROMPT_PALETTE = $Name
    Write-Host "Chevron A palette: $Name (Classic / Sunset / Ocean)"
}

$global:WezPencilPromptCount = 0
function global:prompt {
    # Must capture before Get-Location or any other cmdlet changes the error state.
    $wasSuccessful = $?
    # This is called by PSReadLine::InvokePrompt before AcceptLine. It changes only
    # the live *current* prompt; old scrollback lines are never rewritten.
    if ($global:WezRenderTransient) {
        # Preserve every segment's name, order, width and color.  A one-line
        # terminal can't draw full top/bottom polygon edges: use colored side
        # rails (│) and hollow chevrons () as the outline equivalent.
        $esc = [char]27
        $parts = @($global:WezLastPromptSegments)
        $colors = @($global:WezLastPromptColors)
        if ($parts.Count -eq 0 -or $colors.Count -eq 0) { return '' }
        $ascii = ($global:WezTransientStyle -eq 'ASCII')
        $sideLeft = if ($ascii) { '|' } else { '│' }
        $sideRight = if ($ascii) { '|' } else { '│' }
        $arrow = if ($ascii) { '>' } else { '' }
        $out = ''
        for ($i = 0; $i -lt $parts.Count; $i++) {
            $rgb = $colors[$i % $colors.Count]
            if ($i -gt 0) { $out += "${esc}[38;2;${rgb}m${arrow}" }
            $out += "${esc}[38;2;${rgb}m${sideLeft}" +
                "${esc}[38;2;169;177;214m" + [string]$parts[$i] +
                "${esc}[38;2;${rgb}m${sideRight}"
        }
        $last = $colors[($parts.Count - 1) % $colors.Count]
        return $out + "${esc}[38;2;${last}m${arrow}${esc}[0m "
    }
    $esc = [char]27
    $bel = [char]7
    $control = ''

    # This prompt follows the completed command; return the tab to idle.
    # This runs even if a command failed or was interrupted and PSReadLine
    # did not reach the normal Enter handler.
    Send-WezPaneVar -Name WEZ_RUN -Value idle

    # OSC 133: delimit successive prompts. WezTerm uses these marks for Alt+Up/Down.
    # Custom Enter processing uses PSReadLine only for complete single-line commands.
    if ($global:WezPencilPromptCount -gt 0) {
        $exitStatus = if ($wasSuccessful) { 0 } else { 1 }
        $control += "${esc}]133;D;${exitStatus}${bel}"
    }
    $control += "${esc}]133;A${bel}"

    $location = Get-Location
    $path = [string] $location.Path
    if ($location.Provider.Name -eq 'FileSystem') {
        # OSC 7 also tells WezTerm the live working directory for new tabs/panes.
        $slashPath = $path -replace '\\', '/'
        $hostName = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { 'localhost' }
        $control += "${esc}]7;file://${hostName}/${slashPath}${bel}"
    }

    $shellLabel = if ($PSVersionTable.PSVersion.Major -ge 7) { 'PS7' } else { 'PS5' }
    $segments = @($shellLabel) + @(Get-WezPencilSegments -LocationPath $path)
    # Keep enough space to type, even when a folder tree is very deep.
    $maxCells = 100
    try { $maxCells = [Math]::Max(16, [int]$Host.UI.RawUI.WindowSize.Width - 8) } catch {}
    for ($guard = 0; $guard -lt 12; $guard++) {
        $usedCells = $segments.Count + 1
        foreach ($segment in $segments) { $usedCells += 2 + ([string]$segment).Length }
        if ($usedCells -le $maxCells) { break }
        if ($segments.Count -gt 3) {
            # The oldest levels become an ellipsis; the current folder is always preserved.
            $segments = @($segments[0], '…') + @($segments | Select-Object -Last ($segments.Count - 3))
        } elseif ($segments.Count -eq 3) {
            $segments = @($segments[0], $segments[2])
        } else {
            $maxLabel = [Math]::Max(2, $maxCells - 9)
            if (([string]$segments[1]).Length -gt $maxLabel) {
                $segments[1] = ([string]$segments[1]).Substring(0, $maxLabel - 1) + '…'
            }
            break
        }
    }
    # RGB colors, from pencil eraser to colored shaft and pointed end.
    $colors = $global:WezPencilPalettes[$global:WezPencilPalette]
    if (-not $colors) { $colors = $global:WezPencilPalettes['Classic'] }
    # Freeze the displayed geometry for PSReadLine::InvokePrompt.  This also
    # makes the empty-Enter outline exactly match the active path segments.
    $global:WezLastPromptSegments = @($segments)
    $global:WezLastPromptColors = @($colors)
    $body = ''
    for ($i = 0; $i -lt $segments.Count; $i++) {
        $bg = $colors[$i % $colors.Count]
        if ($i -gt 0) {
            $prevBg = $colors[($i - 1) % $colors.Count]
            # Filled Powerline wedge; the next background makes a true >-shaped notch.
            $body += "${esc}[38;2;${prevBg};48;2;${bg}m"
        }
        # Flat leading edge, continuous colored body, pointed trailing edge: design A.
        $body += "${esc}[38;2;16;19;33;48;2;${bg}m $($segments[$i]) "
    }
    $global:WezPencilPromptVisibleCells = 1
    foreach ($segment in $segments) {
        $global:WezPencilPromptVisibleCells += 2 + ([string]$segment).Length + 1
    }
    $lastBg = $colors[($segments.Count - 1) % $colors.Count]
    # A single pointed tip, not a second line with an unrelated lightning/pencil icon.
    $body += "${esc}[38;2;${lastBg};49m${esc}[0m "
    $global:WezPencilPromptCount += 1
    return $control + $body + "${esc}]133;B${bel}"
}
