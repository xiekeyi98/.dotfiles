# dotfiles

个人开发环境配置，支持 macOS / Linux。

## 快速安装

```bash
# 只读（HTTPS）
curl -fsSL https://raw.githubusercontent.com/xiekeyi98/.dotfiles/master/bootstrap.sh | bash

# 有推送权限（SSH）
curl -fsSL https://raw.githubusercontent.com/xiekeyi98/.dotfiles/master/bootstrap.sh | bash -s -- --ssh
```

`bootstrap.sh` 会自动安装 Homebrew（macOS）、克隆仓库、安装 Brewfile、运行 `install.sh`。

已有仓库时直接运行：

```bash
bash ~/.dotfiles/install.sh
```

## 目录结构

```
.
├── bootstrap.sh          # 新机器一键初始化
├── install.sh            # 主安装脚本（symlink + 插件）
├── Brewfile              # Homebrew 包列表
├── zsh/
│   ├── zshrc             # -> ~/.zshrc
│   └── zshrc.local.template  # 本机配置模板 -> ~/.zshrc.local
├── vim/
│   ├── vimrc             # -> ~/.vimrc
│   └── vimrc.bundles     # -> ~/.vimrc.bundles (vim-plug)
├── git/
│   ├── gitconfig         # -> ~/.gitconfig
│   ├── gitignore_global  # -> ~/.gitignore_global
│   ├── gitmessage        # -> ~/.gitmessage (commit 模板)
│   └── gitconfig.local.template  # 本机配置模板 -> ~/.gitconfig.local
├── claude/
│   ├── install.sh        # Claude Code 配置安装
│   ├── settings.json     # -> ~/.claude/settings.json
│   ├── statusline-command.sh  # p10k 风格状态栏
│   └── commands/         # 自定义 slash commands
├── vscode/
│   └── settings.json     # 参考配置（已改用 VSCode 内置 Settings Sync）
├── macos/
│   └── ramdisk.sh        # RAM disk 工具
└── others/
    └── myclirc           # -> ~/.myclirc (MySQL CLI)
```

## 本机配置

安装时会自动生成以下文件（不被 git 追踪），用于存放机器相关的配置：

- `~/.zshrc.local` — 本机 PATH、代理、别名等
- `~/.gitconfig.local` — 本机 git user、url rewrite 等

## 主要工具

- **Shell**: zsh + oh-my-zsh + powerlevel10k + zsh-autosuggestions
- **Editor**: vim (vim-plug) + VSCode (vim 模式)
- **Git**: conventional commit 模板, git-lfs
- **CLI**: thefuck, mycli, screenfetch
- **AI**: Claude Code (WakaTime 插件, p10k 风格状态栏)
