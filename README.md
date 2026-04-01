# dotfiles

个人开发环境配置，使用 [chezmoi](https://www.chezmoi.io/) 管理，支持 macOS / Linux。

## 全新安装（一行命令）

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply xiekeyi98/.dotfiles
```

会自动：安装 chezmoi → 克隆仓库 → 交互式配置（name/email/是否工作机） → 安装软件 → 部署配置。

## 日常操作

```bash
# 编辑 dotfile（二选一）
vim ~/.zshrc && chezmoi re-add ~/.zshrc   # 直接编辑后同步回源
chezmoi edit ~/.zshrc                      # 编辑源文件

# 提交推送
chezmoi cd && git add -A && git commit -m "update zshrc" && git push

# 另一台机器同步
chezmoi update                             # = git pull + apply

# 新增 dotfile
chezmoi add ~/.tmux.conf

# 查看待应用变更
chezmoi diff

# 删除管理
chezmoi forget ~/.myclirc
```

## 目录结构

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl              # 每台机器的交互式配置
├── .chezmoiignore                  # 不部署到 $HOME 的文件
├── .chezmoiscripts/                # 自动化安装脚本
│   ├── run_once_before_*           # Homebrew, oh-my-zsh, vim-plug 等
│   └── run_once_after_*            # chsh, Claude Code 插件
├── dot_zshrc                       # → ~/.zshrc
├── dot_vimrc                       # → ~/.vimrc
├── dot_vimrc.bundles               # → ~/.vimrc.bundles
├── dot_gitconfig.tmpl              # → ~/.gitconfig（模板，name/email 来自 chezmoi data）
├── dot_gitignore_global            # → ~/.gitignore_global
├── dot_gitmessage                  # → ~/.gitmessage
├── dot_myclirc                     # → ~/.myclirc
├── create_dot_zshrc.local          # → ~/.zshrc.local（仅首次创建）
├── create_dot_gitconfig.local      # → ~/.gitconfig.local（仅首次创建）
├── create_dot_wakatime.cfg         # → ~/.wakatime.cfg（仅首次创建）
├── modify_dot_claude.json          # → ~/.claude.json（注入 editorMode: vim）
├── private_dot_claude/             # → ~/.claude/
│   ├── settings.json               # Claude Code 设置 + 插件列表
│   ├── executable_statusline-command.sh  # p10k 风格状态栏
│   ├── private_plugins/known_marketplaces.json
│   └── skills/analyze-repo/SKILL.md
├── Brewfile                        # Homebrew 包列表（不部署，供脚本引用）
├── vscode/settings.json            # 参考配置（不部署）
└── macos/ramdisk.sh                # RAM disk 工具（不部署）
```

## 机器特定配置

以下文件只在首次 `chezmoi apply` 时创建，之后 chezmoi 不会覆盖：

- `~/.zshrc.local` — 本机 PATH、代理、别名
- `~/.gitconfig.local` — 本机 git user、url rewrite
- `~/.wakatime.cfg` — WakaTime API key

## 主要工具

- **Shell**: zsh + oh-my-zsh + powerlevel10k + zsh-autosuggestions
- **Editor**: vim (vim-plug) + VSCode (vim 模式)
- **Git**: conventional commit 模板, git-lfs
- **CLI**: thefuck, mycli, fastfetch
- **AI**: Claude Code (WakaTime 插件, p10k 风格状态栏, 多 marketplace)
- **管理**: chezmoi + 1Password CLI (密钥管理)
