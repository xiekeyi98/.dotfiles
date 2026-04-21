#!/usr/bin/env bash
# claude-hud statusline launcher
# Dynamically resolves runtime + latest plugin version at runtime,
# so this file is portable across machines (no absolute paths).

cols=$(stty size </dev/tty 2>/dev/null | awk '{print $2}')
export COLUMNS=$(( ${cols:-120} > 4 ? ${cols:-120} - 4 : 1 ))

plugin_dir=$(ls -d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/plugins/cache/*/claude-hud/*/ 2>/dev/null \
    | awk -F/ '{ print $(NF-1) "\t" $0 }' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\t' \
    | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n \
    | tail -1 | cut -f2-)

if [ -z "$plugin_dir" ]; then
    # Plugin not installed — stay silent so statusline doesn't spam.
    exit 0
fi

if command -v bun >/dev/null 2>&1; then
    exec bun --env-file /dev/null "${plugin_dir}src/index.ts"
elif command -v node >/dev/null 2>&1; then
    exec node "${plugin_dir}dist/index.js"
else
    exit 0
fi
