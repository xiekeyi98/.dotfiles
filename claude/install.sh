#!/bin/bash
# Claude Code dotfiles installer
# Usage: bash ~/.dotfiles/claude/install.sh
#
# Skill separation policy (this repo is PUBLIC):
#   - Public/personal skills   -> ~/.dotfiles/claude/skills/  (tracked in git)
#   - Private/internal skills  -> $PRIVATE_SKILLS             (never tracked; provisioned by your org's tooling)
#   - Names matching $PRIVATE_SKILL_RE are refused under dotfiles to prevent accidental leakage.
#   - ~/.claude/skills/ is a real directory with per-skill symlinks from both sources
#     (dotfiles takes precedence on name collision).
#
# Machine-local overrides: if ~/.dotfiles/claude/install.local.sh exists it is sourced
# before skill linking — put any org-specific PRIVATE_SKILLS path or PRIVATE_SKILL_RE
# pattern there (it is gitignored).

set -e

DOTFILES_CLAUDE="$HOME/.dotfiles/claude"
CLAUDE_HOME="$HOME/.claude"

# Defaults — override in install.local.sh on machines that have a private skills source.
PRIVATE_SKILLS=""
PRIVATE_SKILL_RE='^(private-.*|internal-.*)$'

LOCAL_OVERRIDES="$DOTFILES_CLAUDE/install.local.sh"
[ -f "$LOCAL_OVERRIDES" ] && source "$LOCAL_OVERRIDES"

# 确保 ~/.claude 目录存在
mkdir -p "$CLAUDE_HOME"
mkdir -p "$CLAUDE_HOME/plugins"

# 创建 symlink 的辅助函数
# 如果目标已存在且不是 symlink，先备份
link_file() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        echo "  [skip] $src not found"
        return
    fi

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        echo "  [backup] $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -s "$src" "$dst"
    echo "  [link] $src -> $dst"
}

echo "==> Setting up Claude Code config..."

# settings.json
link_file "$DOTFILES_CLAUDE/settings.json" "$CLAUDE_HOME/settings.json"

# statusline script
link_file "$DOTFILES_CLAUDE/statusline-command.sh" "$CLAUDE_HOME/statusline-command.sh"

# plugins/known_marketplaces.json
link_file "$DOTFILES_CLAUDE/known_marketplaces.json" "$CLAUDE_HOME/plugins/known_marketplaces.json"

# custom commands (skills)
if [ -d "$DOTFILES_CLAUDE/commands" ]; then
    link_file "$DOTFILES_CLAUDE/commands" "$CLAUDE_HOME/commands"
fi

# custom skills — real directory with per-skill symlinks (not a whole-dir symlink)
# so private skills from an external source can coexist with personal ones from dotfiles
# without leaking private skills into this public repo.
if [ -L "$CLAUDE_HOME/skills" ]; then
    rm "$CLAUDE_HOME/skills"
    echo "  [unlink] $CLAUDE_HOME/skills (was whole-dir symlink, switching to per-skill)"
fi
mkdir -p "$CLAUDE_HOME/skills"

# 1) Public/personal skills from dotfiles — with name guardrail
if [ -d "$DOTFILES_CLAUDE/skills" ]; then
    for skill in "$DOTFILES_CLAUDE/skills"/*; do
        [ -e "$skill" ] || continue
        name=$(basename "$skill")
        if [[ "$name" =~ $PRIVATE_SKILL_RE ]]; then
            echo "  [REFUSE] $name matches PRIVATE_SKILL_RE — do NOT put it under dotfiles (public repo)."
            echo "           Move it to \$PRIVATE_SKILLS and remove from dotfiles."
            continue
        fi
        link_file "$skill" "$CLAUDE_HOME/skills/$name"
    done
fi

# 2) Private skills from $PRIVATE_SKILLS (configured via install.local.sh). Dotfiles wins on collision.
if [ -n "$PRIVATE_SKILLS" ] && [ -d "$PRIVATE_SKILLS" ]; then
    for skill in "$PRIVATE_SKILLS"/*; do
        [ -e "$skill" ] || continue
        name=$(basename "$skill")
        if [ -e "$CLAUDE_HOME/skills/$name" ] && [ ! -L "$CLAUDE_HOME/skills/$name" ]; then
            echo "  [skip] $name exists as real file/dir in ~/.claude/skills/, not overwriting"
            continue
        fi
        link_file "$skill" "$CLAUDE_HOME/skills/$name"
    done
elif [ -n "$PRIVATE_SKILLS" ]; then
    echo "  [info] PRIVATE_SKILLS=$PRIVATE_SKILLS not found — skipping"
fi

# Inject editorMode into ~/.claude.json (global state file, not suitable for symlink)
CLAUDE_JSON="$HOME/.claude.json"
if command -v jq &>/dev/null; then
    if [ -f "$CLAUDE_JSON" ]; then
        if [ "$(jq -r '.editorMode // empty' "$CLAUDE_JSON")" != "vim" ]; then
            tmp=$(mktemp)
            jq '.editorMode = "vim"' "$CLAUDE_JSON" > "$tmp" && mv "$tmp" "$CLAUDE_JSON"
            echo "  [set] editorMode = vim in $CLAUDE_JSON"
        else
            echo "  [ok] editorMode already set to vim"
        fi
    else
        echo '{"editorMode":"vim"}' > "$CLAUDE_JSON"
        echo "  [create] $CLAUDE_JSON with editorMode = vim"
    fi
else
    echo "  [warn] jq not found, skipping editorMode injection"
fi

# Install plugins (requires claude CLI)
if command -v claude &>/dev/null; then
    echo "==> Installing Claude Code plugins..."
    # Strip machine-specific fields (installLocation, lastUpdated) from known_marketplaces.json
    # These are runtime state that 'marketplace update' will regenerate with correct local paths
    if [ -f "$CLAUDE_HOME/plugins/known_marketplaces.json" ]; then
        tmp=$(mktemp)
        jq 'to_entries | map(.value |= {source: .source}) | from_entries' \
            "$CLAUDE_HOME/plugins/known_marketplaces.json" > "$tmp" && \
            mv "$tmp" "$CLAUDE_HOME/plugins/known_marketplaces.json"
    fi
    claude plugin marketplace update 2>/dev/null || true
    # Install enabled plugins from settings
    for plugin in $(jq -r '.enabledPlugins // {} | keys[]' "$DOTFILES_CLAUDE/settings.json" 2>/dev/null); do
        if claude plugin list 2>/dev/null | grep -q "$plugin"; then
            echo "  [ok] $plugin already installed"
        else
            echo "  [install] $plugin"
            claude plugin install "$plugin" 2>/dev/null || echo "  [warn] failed to install $plugin"
        fi
    done
else
    echo "  [skip] claude CLI not found, install plugins manually"
fi

echo "==> Done! Claude Code config has been linked."
