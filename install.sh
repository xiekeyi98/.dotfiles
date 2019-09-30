# vim

# ln -s ~/.dotfiles/vim ~/.vim
# Install Plug 
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
ln -s ~/.dotfiles/vim/vimrc.bundles ~/.vimrc.bundles

# for oh-my-zsh
ln -s ~/.dotfiles/zsh/oh-my-zsh/ ~/.oh-my-zsh # install oh-my-zsh
ln -s ~/.dotfiles/zsh/zshrc ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

chsh -s $(which zsh)

# for config files
# ln -s ~/.dotfiles/config/gitconfig ~/.gitconfig
# ln -s ~/.dotfiles/config/gitignore_global ~/.gitignore_global
# ln -s ~/.dotfiles/config/ssh ~/.ssh
