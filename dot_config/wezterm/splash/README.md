# LazyVim-inspired WEZTERM logo (v5)

`splash/wezt-logo.txt` is the canonical 8-line Unicode logo. It reproduces the
approved six-row WEZTERM block/double-line art, followed by a two-layer cast
shadow. The main body uses `█╔╗╚╝═║`, the first extrusion uses `▓┌┐└┘─│`, and
the distant shadow uses `░`. All glyphs occupy one terminal cell.

The banner is displayed by `prompts/startup.ps1` (PowerShell), by `prompts/gitbash.sh`
when sourced from an interactive `~/.bashrc`, and read for Lua previews by
`animations/logo.lua`. Don't edit only one of these renderers.

At terminal widths narrower than the artwork, the welcome output falls back to
`W E Z T E R M`. The logo inherits the terminal font stack, prioritizing
`JF Dot K14` / `JF Dot M+ 10`. No extra font file is included here.

The browser/PIL preview has sub-cell shadow offsets, which can't be reproduced
exactly with text cells. This version approximates it using an offset-character
shadow, and does not change the background or the selected Chevron-A prompt.
