#!/usr/bin/env bash
# Add this line at the end of interactive ~/.bashrc:
# source "$HOME/.config/wezterm/prompts/gitbash.sh"
case $- in *i*) ;; *) return 0 ;; esac
[[ ${WEZ_VISUAL_BASH_INITIALIZED:-} == 1 ]] && return 0
WEZ_VISUAL_BASH_INITIALIZED=1

export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
printf '\033]1337;SetUserVar=WEZ_SHELL=R2l0IEJhc2g=\007'
printf '\033]0;Git Bash | WezTerm\007'

wez_welcome() {
  [[ ${WEZTERM_WELCOME:-1} == 0 ]] && return 0
  local banner="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm/splash/wezt-logo.txt"
  local cols=${COLUMNS:-100} line i=0 pad ch active='' shade
  local -a face_colors=('150;175;255' '148;174;255' '146;173;254' '142;171;254'
                        '136;167;252' '127;165;251' '121;158;242' '121;158;242')
  local banner_width=0
  if [[ -r $banner ]]; then
    IFS= read -r line < "$banner"
    banner_width=${#line}
  fi
  printf '\n'
  if (( cols >= banner_width + 2 && banner_width > 0 )) && [[ -r $banner ]]; then
    while IFS= read -r line || [[ -n $line ]]; do
      (( pad = (cols - ${#line}) / 2 ))
      (( pad < 0 )) && pad=0
      printf '%*s' "$pad" ''
      active=''
      for (( j=0; j<${#line}; j++ )); do
        ch=${line:j:1}
        case "$ch" in
          █|╔|╗|╚|╝|═|║) shade=${face_colors[i % ${#face_colors[@]}]} ;;
          ▓|┌|┐|└|┘|─|│) shade='68;88;131' ;;
          ░) shade='40;56;87' ;;
          *) shade='' ;;
        esac
        if [[ $shade != "$active" ]]; then
          if [[ -n $shade ]]; then printf '\033[38;2;%sm' "$shade"; else printf '\033[0m'; fi
          active=$shade
        fi
        printf '%s' "$ch"
      done
      printf '\033[0m\n'
      (( i += 1 ))
      [[ ${WEZTERM_ANIMATE:-1} != 0 ]] && sleep 0.035
    done < "$banner"
  else
    printf '\033[38;2;187;154;247m W E Z T E R M \033[0m\n'
  fi
  printf '\n\033[38;2;130;143;182m  Alt+↑/↓: previous/next command  |  Alt+End: live prompt  |  F1: help\033[0m\n\n'
}

wez_welcome

# Show Fastfetch once after the 3D WEZTERM logo; never block shell startup if absent.
wez_fastfetch() {
  [[ ${WEZTERM_FASTFETCH:-1} == 0 ]] && return 0
  if command -v fastfetch >/dev/null 2>&1; then
    if [[ ${WEZTERM_FASTFETCH_LOGO:-0} == 1 ]]; then
      fastfetch || true
    else
      fastfetch -l none || true
    fi
    printf '\n'
  else
    printf '\033[38;2;130;143;182m  Fastfetch not installed. Install: winget install fastfetch\033[0m\n\n'
  fi
}
wez_fastfetch

# Bash 4.4+ PS0 emits execution START immediately before a command runs.
# OSC 1337 values are precomputed base64 (running=cnVubmluZw==, idle=aWRsZQ==).
# This leaves all normal commands running in the current shell, without
# an extra process, and never touches program stdout/stderr.
if [[ -n ${WEZTERM_PANE:-} && ${WEZTERM_USE_STARSHIP:-0} != 1 ]]; then
  PS0="${PS0:-}"$'\033]133;C\007\033]1337;SetUserVar=WEZ_RUN=cnVubmluZw==\007'
fi

# A quick native test: wez_tab_test 7 (no capture and no subprocess wrapper).
wez_tab_test() {
  local duration=${1:-7}
  [[ $duration =~ ^[1-9][0-9]?$ ]] || { printf 'Usage: wez_tab_test SECONDS (1-99)\n'; return 2; }
  printf '\033]1337;SetUserVar=WEZ_RUN=cnVubmluZw==\007'
  sleep "$duration"
  printf '\033]1337;SetUserVar=WEZ_RUN=aWRsZQ==\007'
}

# Keep readline's native completion and history behavior; don't hijack Tab/Enter.
if [[ ${WEZTERM_SUGGESTIONS:-1} != 0 ]]; then
  bind 'set colored-stats on' 2>/dev/null || true
  bind 'set show-all-if-ambiguous on' 2>/dev/null || true
fi

# Starship is opt-in: the native implementation renders one colored path block per level.
if [[ ${WEZTERM_USE_STARSHIP:-0} == 1 ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
  return 0
fi

# Default Chevron A is flat-left with a filled > wedge between colored segments.
# Change colors in this shell without editing chezmoi: wez_palette sunset
wez_palette() {
  case "${1:-classic}" in
    classic|sunset|ocean) export WEZTERM_PROMPT_PALETTE="${1:-classic}" ;;
    *) printf 'Palette: classic / sunset / ocean\n' >&2; return 2 ;;
  esac
  printf 'Chevron A palette: %s\n' "$WEZTERM_PROMPT_PALETTE"
}
WEZ_PENCIL_PROMPT_COUNT=0
wez_prompt_refresh() {
  local last=$? status=0
  (( last == 0 )) || status=1
  if (( WEZ_PENCIL_PROMPT_COUNT > 0 )); then
    printf '\033]133;D;%s\007' "$status"
  fi
  printf '\033]1337;SetUserVar=WEZ_RUN=aWRsZQ==\007'
  printf '\033]7;file://%s%s\007' "${HOSTNAME:-localhost}" "$PWD"
  (( WEZ_PENCIL_PROMPT_COUNT += 1 ))

  local display="$PWD" home="$HOME" part
  [[ $display == "$home" ]] && display='~'
  [[ $display == "$home/"* ]] && display="~${display#"$home"}"
  local -a pathParts=() allParts=()
  local IFS='/'
  read -r -a pathParts <<< "$display"
  local -a filtered=()
  for part in "${pathParts[@]}"; do [[ -n $part ]] && filtered+=("$part"); done
  (( ${#filtered[@]} > 0 )) || filtered=('~')
  if (( ${#filtered[@]} > 6 )); then
    pathParts=("${filtered[0]}" '…' "${filtered[@]: -4}")
  else
    pathParts=("${filtered[@]}")
  fi
  allParts=('BASH' "${pathParts[@]}")
  # Leave space to type instead of letting a very deep path wrap by default.
  local maxCells=$(( ${COLUMNS:-100} - 8 )) usedCells i
  (( maxCells < 16 )) && maxCells=16
  while :; do
    usedCells=$(( ${#allParts[@]} + 1 ))
    for part in "${allParts[@]}"; do (( usedCells += ${#part} + 2 )); done
    (( usedCells <= maxCells )) && break
    if (( ${#allParts[@]} > 3 )); then
      allParts=('BASH' '…' "${allParts[@]: -$((${#allParts[@]} - 3))}")
    elif (( ${#allParts[@]} == 3 )); then
      allParts=('BASH' "${allParts[2]}")
    else
      # All non-path cells take 11 slots for BASH and the wedge glyphs.
      # The previous maxCells-9 calculation could overflow a narrow terminal.
      part=${allParts[1]}
      local keep=$(( maxCells - 11 ))
      (( keep < 1 )) && keep=1
      if (( ${#part} > keep )); then
        if (( keep == 1 )); then allParts[1]='…'
        else allParts[1]="${part:0:$((keep-1))}…"
        fi
      fi
      break
    fi
  done
  local -a colors
  case "${WEZTERM_PROMPT_PALETTE:-classic}" in
    sunset|Sunset) colors=('247;118;142' '255;158;100' '224;175;104' '187;154;247' '125;207;255') ;;
    ocean|Ocean) colors=('122;162;247' '125;207;255' '158;206;106' '187;154;247' '224;175;104') ;;
    *) colors=('187;154;247' '125;207;255' '224;175;104' '158;206;106' '122;162;247') ;;
  esac
  local prompt='\[\e]133;A\a\]' curr prev i
  for (( i=0; i<${#allParts[@]}; i++ )); do
    curr=${colors[i % ${#colors[@]}]}
    if (( i > 0 )); then
      prev=${colors[(i - 1) % ${#colors[@]}]}
      prompt+="\[\e[38;2;${prev};48;2;${curr}m\]"
    fi
    part=${allParts[i]}
    (( ${#part} > 25 )) && part="${part:0:12}…${part: -10}"
    prompt+="\\[\\e[38;2;16;19;33;48;2;${curr}m\\] ${part} "
  done
  curr=${colors[(${#allParts[@]} - 1) % ${#colors[@]}]}
  prompt+="\\[\\e[38;2;${curr};49m\\]\\[\\e[0m\\] \\[\\e]133;B\\a\\]"
  PS1=$prompt
}

# Retain existing PROMPT_COMMAND hooks, while preserving our status from the last command.
if [[ $(declare -p PROMPT_COMMAND 2>/dev/null) == declare\ -a* ]]; then
  PROMPT_COMMAND=(wez_prompt_refresh "${PROMPT_COMMAND[@]}")
elif [[ -n ${PROMPT_COMMAND:-} ]]; then
  PROMPT_COMMAND="wez_prompt_refresh; ${PROMPT_COMMAND}"
else
  PROMPT_COMMAND=wez_prompt_refresh
fi
