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

# plugins/known_marketplaces.json
link_file "$DOTFILES_CLAUDE/known_marketplaces.json" "$CLAUDE_HOME/plugins/known_marketplaces.json"

# custom commands (skills)
if [ -d "$DOTFILES_CLAUDE/commands" ]; then
    link_file "$DOTFILES_CLAUDE/commands" "$CLAUDE_HOME/commands"
fi

echo "==> Done! Claude Code config has been linked."
