#!/bin/bash
# Link per-skill from ~/.agents/skills into ~/.claude/skills.
#
# ~/.agents/skills is the convention for work-provisioned / private skills
# (bytedcli, lark-*, byted-*, internal-*, etc.). These MUST NEVER be tracked
# in this public repo — they live on the machine, and we just create
# per-skill symlinks so Claude Code picks them up alongside public skills.
#
# No-op on machines without ~/.agents/skills (personal / fresh installs).
# Idempotent: safe to re-run; silent when nothing changes.

set -e

AGENTS_SKILLS="$HOME/.agents/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"

[ -d "$AGENTS_SKILLS" ] || exit 0

mkdir -p "$CLAUDE_SKILLS"

for skill in "$AGENTS_SKILLS"/*; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    target="$CLAUDE_SKILLS/$name"

    # Don't clobber a real directory (a public skill of the same name wins).
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        continue
    fi

    # Already correctly linked — skip quietly.
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$skill" ]; then
        continue
    fi

    [ -L "$target" ] && rm "$target"
    ln -s "$skill" "$target"
    echo "  [link] private skill: $name"
done
