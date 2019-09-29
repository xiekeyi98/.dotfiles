# vim

# Install Plug 
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


# ln -s ~/.dotfiles/vim ~/.vim
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
ln -s ~/.dotfiles/vim/vimrc.bundles ~/.vimrc.bundles

# for oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
ln -s ~/.dotfiles/zsh/zshrc ~/.zshrc

# for config files
# ln -s ~/.dotfiles/config/gitconfig ~/.gitconfig
# ln -s ~/.dotfiles/config/gitignore_global ~/.gitignore_global
# ln -s ~/.dotfiles/config/ssh ~/.ssh
