# Called with PowerShell -NoExit -Command from WezTerm. Keep the shell interactive.
. (Join-Path $PSScriptRoot 'powershell.ps1')

function global:Show-WezWelcome {
    if ($env:WEZTERM_WELCOME -eq '0') { return }
    $esc = [char]27
    $width = 95
    try { $width = [int] $Host.UI.RawUI.WindowSize.Width } catch {}
    $width = [Math]::Max(20, $width)
    $logoPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'splash/wezt-logo.txt'

    # Use the exact 8-row LazyVim box/double-counter logo from the shared text asset.
    # Fall back to compact lettering when a pane is too narrow.
    $lines = @('W E Z T E R M')
    if (Test-Path -LiteralPath $logoPath) {
        $candidate = @(Get-Content -LiteralPath $logoPath -Encoding UTF8)
        if ($candidate.Count -gt 0) {
            $logoWidth = ($candidate | Measure-Object -Property Length -Maximum).Maximum
            if ($width -ge ($logoWidth + 2)) { $lines = $candidate }
        }
    }
    $faceColors = @('150;175;255', '148;174;255', '146;173;254', '142;171;254',
                    '136;167;252', '127;165;251', '121;158;242', '121;158;242')
    $frontGlyphs = '█╔╗╚╝═║'
    $extrudeGlyphs = '▓┌┐└┘─│'
    Write-Host ''
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = [string] $lines[$i]
        $pad = [Math]::Max(0, [int][Math]::Floor(($width - $line.Length) / 2))
        $render = (' ' * $pad)
        $currentColor = ''
        foreach ($ch in $line.ToCharArray()) {
            $glyph = [string] $ch
            $color = if ($frontGlyphs.Contains($glyph)) { $faceColors[$i % $faceColors.Count] }
                     elseif ($extrudeGlyphs.Contains($glyph)) { '68;88;131' }
                     elseif ($glyph -eq '░') { '40;56;87' }
                     else { '' }
            if ($color -ne $currentColor) {
                if ($color) { $render += "${esc}[38;2;${color}m" } else { $render += "${esc}[0m" }
                $currentColor = $color
            }
            $render += [string]$ch
        }
        Write-Host ($render + "${esc}[0m")
        if ($env:WEZTERM_ANIMATE -ne '0' -and $lines.Count -gt 1) { Start-Sleep -Milliseconds 35 }
    }
    Write-Host ''
    $hint = 'Alt+Up/Down: command history    Alt+End: live prompt    F1: help'
    if ($width -lt 76) { $hint = 'Alt+Up/Down: history    F1: help' }
    $pad = [Math]::Max(0, [int][Math]::Floor(($width - $hint.Length) / 2))
    Write-Host ((' ' * $pad) + "${esc}[38;2;130;143;182m" + $hint + "${esc}[0m")
    Write-Host ''
}

function global:Show-WezFastfetch {
    if ($env:WEZTERM_FASTFETCH -eq '0') { return }
    if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
        Write-Host '  Fastfetch not installed. Install: winget install fastfetch' -ForegroundColor DarkGray
        return
    }
    # The 3D WEZTERM artwork is the hero logo. Suppress Fastfetch's second logo
    # unless WEZTERM_FASTFETCH_LOGO=1, while keeping its complete info modules.
    try {
        if ($env:WEZTERM_FASTFETCH_LOGO -eq '1') {
            & fastfetch
        } else {
            & fastfetch -l none
        }
        Write-Host ''
    } catch {
        Write-Warning "Fastfetch could not start: $_"
    }
}

Show-WezWelcome
Show-WezFastfetch
