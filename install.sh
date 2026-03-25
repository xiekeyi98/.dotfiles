#!/bin/bash
set -e

DOTFILES="$HOME/.dotfiles"

# 创建 symlink 的辅助函数
# 如果目标已存在且不是 symlink，先备份；如果已是正确的 symlink，跳过
link_file() {
    local src="$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        echo "  [skip] $src not found"
        return
    fi

    if [ -L "$dst" ]; then
        local current_target
        current_target=$(readlink "$dst")
        if [ "$current_target" = "$src" ]; then
            echo "  [ok] $dst already linked"
            return
        fi
        rm "$dst"
    elif [ -e "$dst" ]; then
        echo "  [backup] $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -s "$src" "$dst"
    echo "  [link] $src -> $dst"
}

# Copy local config templates (not symlinked — machine-specific, not tracked by git)
copy_template() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$dst" ]; then
        cp "$src" "$dst"
        echo "  [copy] $src -> $dst (edit this for machine-specific config)"
    else
        echo "  [ok] $dst already exists, skipping"
    fi
}

# Brewfile (macOS only)
if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
    echo "==> Installing Homebrew packages..."
    brew bundle install --file="$DOTFILES/Brewfile" --no-lock
fi

# vim
echo "==> Setting up vim..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
link_file "$DOTFILES/vim/vimrc" "$HOME/.vimrc"
link_file "$DOTFILES/vim/vimrc.bundles" "$HOME/.vimrc.bundles"
link_file "$DOTFILES/others/myclirc" "$HOME/.myclirc"

# for oh-my-zsh
echo "==> Setting up oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
# 因为 git submoudle 的缘故，直接软链接好像不行，还是安装吧
# ln -s ~/.dotfiles/zsh/oh-my-zsh/ ~/.oh-my-zsh # install oh-my-zsh
link_file "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"
copy_template "$DOTFILES/zsh/zshrc.local" "$HOME/.zshrc.local"
# 安装 zsh 自动补全插件
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi
# 安装 pwerleverl10k 插件
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi
echo "Install font please."
# 安装 zsh-syntax-hightlight
#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 和 autosugg 兼容不好
# 应该不需要，10k 应该可以兼容
# git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k


# 切换 shell 默认为 zsh
chsh -s "$(which zsh)"

# 以下工具通过 Brewfile 安装 (macOS) 或手动安装 (Linux):
# screenfetch, lshw, mycli, git cz, git cz-emoji
# echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc
# echo '{ "path": "cz-emoji" }' > ~/.czrc

# for config files
echo "==> Setting up git config..."
link_file "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES/git/gitignore_global" "$HOME/.gitignore_global"
link_file "$DOTFILES/git/gitmessage" "$HOME/.gitmessage"
copy_template "$DOTFILES/git/gitconfig.local" "$HOME/.gitconfig.local"
# ln -s ~/.dotfiles/config/ssh ~/.ssh


# brew cask install qlcolorcode betterzipql qlimagesize // macos 预览
# brew install --cask rectangle // 屏幕调整工具

# install istat menus , alfred , surge , etc..

# for git
git config --global core.excludesfile ~/.gitignore_global # 全局忽略 gitignore_global 里的文件

# for wakatime (shared by vim, VS Code, Claude Code, etc.)
echo "==> Setting up WakaTime..."
WAKATIME_CFG="$HOME/.wakatime.cfg"
if [ -f "$WAKATIME_CFG" ]; then
    echo "  [ok] $WAKATIME_CFG already exists"
else
    printf "  Enter your WakaTime API key (leave empty to skip): "
    read -r WAKATIME_KEY
    if [ -n "$WAKATIME_KEY" ]; then
        cat > "$WAKATIME_CFG" <<EOF
[settings]
api_key = $WAKATIME_KEY
EOF
        echo "  [create] $WAKATIME_CFG"
    else
        echo "  [skip] No API key provided"
    fi
fi

# for claude code
echo "==> Setting up Claude Code..."
bash "$DOTFILES/claude/install.sh"
