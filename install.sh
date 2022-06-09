# vim

# ln -s ~/.dotfiles/vim ~/.vim # 应该不需要这个，手动安装用
 
# Install Plug 
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc # vimrc 软连接过去
ln -s ~/.dotfiles/vim/vimrc.bundles ~/.vimrc.bundles # vimrc 包含该文件，插件配置文件，软连接过去。
ln -s ~/.dotfiles/others/myclirc ~/.myclirc # mycli

# for oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 因为 git submoudle 的缘故，直接软链接好像不行，还是安装吧
# ln -s ~/.dotfiles/zsh/oh-my-zsh/ ~/.oh-my-zsh # install oh-my-zsh
mv ~/.zshrc ~/.zshrc.bak # 备份原来的
ln -s ~/.dotfiles/zsh/zshrc ~/.zshrc # zshrc 配置软连接过去
# 安装 zsh 自动补全插件
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# 安装 pwerleverl10k 插件
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
echo "Install font please."
# 安装 zsh-syntax-hightlight
#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 和 autosugg 兼容不好
# 应该不需要，10k 应该可以兼容
# git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k 


# 切换 shell 默认为 zsh
chsh -s $(which zsh)

# 提醒安装这两个
echo "install screenfetch"
echo "install lshw"
echo "install git cz"
echo "install git  cz-emoji"
echo "install mycli"
# echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc
# echo '{ "path": "cz-emoji" }' > ~/.czrc

# for config files
# ln -s ~/.dotfiles/config/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git/gitignore_global ~/.gitignore_global #把 git 全局忽略的文件配过去
ln -s ~/.dotfiles/git/gitmessage ~/.gitmessage #把 git 全局忽略的文件配过去
# ln -s ~/.dotfiles/config/ssh ~/.ssh


# brew cask install qlcolorcode betterzipql qlimagesize // macos 预览
# brew install --cask rectangle // 屏幕调整工具

# install istat menus , alfred , surge , etc..

# for git
git config --global core.excludesfile ~/.gitignore_global # 全局忽略 gitignore_global 里的文件



