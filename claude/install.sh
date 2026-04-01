#!/bin/bash
# Claude Code dotfiles installer
# Usage: bash ~/.dotfiles/claude/install.sh

set -e

DOTFILES_CLAUDE="$HOME/.dotfiles/claude"
CLAUDE_HOME="$HOME/.claude"

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

# custom skills
if [ -d "$DOTFILES_CLAUDE/skills" ]; then
    link_file "$DOTFILES_CLAUDE/skills" "$CLAUDE_HOME/skills"
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
