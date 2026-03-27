#!/usr/bin/env bash
# Claude Code statusline — Powerlevel10k-inspired
# NerdFont icons; ANSI colours matching p10k vcs palette.

input=$(cat)

# colours (must use $'...' so \033 becomes a real ESC byte)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
WHITE=$'\033[0;37m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
RST=$'\033[0m'

# ── LEFT segments ─────────────────────────────────────────────────────────────

#  os_icon  (Apple NerdFont glyph)
OS_ICON=$'\xEF\x85\xB9'   # U+F179 = Apple logo

#  dir, model, context window, rate limits — single jq pass
IFS=$'\t' read -r CWD MODEL USED_PCT FIVE_PCT WEEK_PCT < <(
  echo "$input" | jq -r '[
    (.workspace.current_dir // .cwd),
    (.model.display_name // .model.id // "Claude"),
    (.context_window.used_percentage // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.seven_day.used_percentage // "")
  ] | @tsv'
)
DIR="${CWD/#$HOME/~}"

#  vcs  — git info from cwd
STAGED_ICON=$'\xEF\x81\x95'    # U+F055
UNSTAGED_ICON=$'\xEF\x81\xB1'  # U+F071
UNTRACKED_ICON=$'\xEF\x80\x8D' # U+F00D
BRANCH_ICON=$'\xEF\x87\x93'    # U+F1D3
INCOMING_ICON=$'\xEF\x82\xAB'  # U+F0AB
OUTGOING_ICON=$'\xEF\x82\xAA'  # U+F0AA

git_segment=""
if git -C "$CWD" rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null || git -C "$CWD" rev-parse --short HEAD 2>/dev/null)

    # count staged / unstaged / untracked via single git status
    STAGED=0; UNSTAGED=0; UNTRACKED=0
    while IFS= read -r line; do
        [[ "$line" == '?? '* ]] && (( UNTRACKED++ )) && continue
        [[ "${line:0:1}" != ' ' && "${line:0:1}" != '?' ]] && (( STAGED++ ))
        [[ "${line:1:1}" != ' ' && "${line:1:1}" != '?' ]] && (( UNSTAGED++ ))
    done < <(git -C "$CWD" status --porcelain 2>/dev/null)

    # ahead/behind in single rev-list call
    read -r INCOMING OUTGOING < <(git -C "$CWD" rev-list --left-right --count @{u}...HEAD 2>/dev/null || echo "0 0")

    # pick colour: modified > untracked > clean
    if [ "$UNSTAGED" -gt 0 ] || [ "$STAGED" -gt 0 ]; then
        GIT_COLOR="$RED"
    elif [ "$UNTRACKED" -gt 0 ]; then
        GIT_COLOR="$YELLOW"
    else
        GIT_COLOR="$GREEN"
    fi

    git_segment="${GIT_COLOR}${BRANCH_ICON} ${BRANCH}"

    [ "$STAGED" -gt 0 ]    && git_segment+=" ${STAGED_ICON}${STAGED}"
    [ "$UNSTAGED" -gt 0 ]  && git_segment+=" ${UNSTAGED_ICON}${UNSTAGED}"
    [ "$UNTRACKED" -gt 0 ] && git_segment+=" ${UNTRACKED_ICON}${UNTRACKED}"
    [ "$INCOMING" -gt 0 ]  && git_segment+=" ${INCOMING_ICON}${INCOMING}"
    [ "$OUTGOING" -gt 0 ]  && git_segment+=" ${OUTGOING_ICON}${OUTGOING}"

    git_segment+="${RST}"
fi

# ── RIGHT segments ────────────────────────────────────────────────────────────

#  context window usage
if [ -n "$USED_PCT" ]; then
    USED_INT=$(printf '%.0f' "$USED_PCT")
    if   [ "$USED_INT" -ge 80 ]; then CTX_COLOR="$RED"
    elif [ "$USED_INT" -ge 50 ]; then CTX_COLOR="$YELLOW"
    else                               CTX_COLOR="$GREEN"
    fi
    CTX_SEGMENT="${CTX_COLOR}ctx:${USED_INT}%${RST}"
else
    CTX_SEGMENT=""
fi

#  rate limits (Claude.ai subscription)
RATE_SEGMENT=""
if [ -n "$FIVE_PCT" ]; then
    RATE_SEGMENT+="${DIM}5h:$(printf '%.0f' "$FIVE_PCT")%${RST}"
fi
if [ -n "$WEEK_PCT" ]; then
    [ -n "$RATE_SEGMENT" ] && RATE_SEGMENT+=" "
    RATE_SEGMENT+="${DIM}7d:$(printf '%.0f' "$WEEK_PCT")%${RST}"
fi

#  time
TIME_NOW=$(date "+%m-%d %H:%M:%S")

# ── assemble ──────────────────────────────────────────────────────────────────
# Left side
LEFT="${BOLD}${WHITE}${OS_ICON}${RST}  ${BLUE}${DIR}${RST}"
[ -n "$git_segment" ] && LEFT+="  ${git_segment}"

# Right side (space-separated, non-empty parts only)
RIGHT_PARTS=()
[ -n "$MODEL" ]        && RIGHT_PARTS+=("${DIM}${WHITE}${MODEL}${RST}")
[ -n "$CTX_SEGMENT" ]  && RIGHT_PARTS+=("$CTX_SEGMENT")
[ -n "$RATE_SEGMENT" ] && RIGHT_PARTS+=("$RATE_SEGMENT")
RIGHT_PARTS+=("${DIM}${WHITE}${TIME_NOW}${RST}")

RIGHT=""
for part in "${RIGHT_PARTS[@]}"; do
    [ -n "$RIGHT" ] && RIGHT+="  "
    RIGHT+="$part"
done

printf "%s  |  %s\n" "$LEFT" "$RIGHT"
