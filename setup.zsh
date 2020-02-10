#!/usr/bin/zsh

target=$1

if [[ $target != "lpt" && $target != "pc" && $target != "remote" ]]; then
    echo -e "\nInvalid target"
    exit 1
fi

# {{ Plugin managers
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

PLUGVIM=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs $PLUGVIM
# }}

# {{ ZSH
rm -r $HOME/.config/zsh 2> /dev/null

ln -sf $HOME/Dotfiles/rcfiles/zshrc $HOME/.zshrc
ln -s $HOME/Dotfiles/config_zsh $HOME/.config/zsh

source "$HOME/.zgen/zgen.zsh"
zgen reset && zgen update
# }}

# {{ VIM
rm -r $HOME/.config/vim 2> /dev/null
rm -r $HOME/.vim 2> /dev/null

ln -s $HOME/Dotfiles/vim $HOME/.vim
ln -s $HOME/Dotfiles/config_vim $HOME/.config/vim
ln -sf $HOME/Dotfiles/rcfiles/vimrc $HOME/.vimrc

mkdir $HOME/.vim/swapfiles $HOME/.vim/backups $HOME/.vim/undo 2> /dev/null
vim +PlugUpdate +qall

if [[ -d $HOME/.config/nvim ]]; then
    ln -sf $HOME/.vimrc $HOME/.config/nvim/init.vim
    ln -s $HOME/.vim/* $HOME/.config/nvim/
fi
# }}

# {{ SCREEN
ln -sf $HOME/Dotfiles/rcfiles/screenrc $HOME/.screenrc
# }}

# {{ TMUX
ln -sf $HOME/Dotfiles/tmux/conf $HOME/.tmux.conf
# }}

# {{ PROFILE
ln -sf $HOME/Dotfiles/rcfiles/profile $HOME/.profile
# }}

# {{ TERMCOLORS
ln -sf $HOME/Dotfiles/rcfiles/termcolors.sh $HOME/.termcolors.sh
# }}

# {{ RANGER
rm -r $HOME/.config/ranger 2> /dev/null
ln -s $HOME/Dotfiles/config_ranger $HOME/.config/ranger
# }}

# {{ HG
ln -sf $HOME/Dotfiles/rcfiles/hgrc $HOME/.hgrc
#}}

# {{ GIT
rm ~/.gitconfig
ln -s $HOME/Dotfiles/rcfiles/gitconfig $HOME/.gitconfig
# }}

# {{ AG
ln -sf $HOME/Dotfiles/rcfiles/agignore $HOME/.agignore
#}}

if [[ $target == "pc" || $target == "lpt" ]]; then

    # {{ PIP THINGS
    ln -sf $HOME/Dotfiles/rcfiles/pylintrc $HOME/.pylintrc
    ln -sf $HOME/Dotfiles/rcfiles/style.yapf $HOME/.style.yapf

    echo "Installing pip and updating some plugins."
    pip install --user --upgrade pip > /dev/null
    pip install --user --upgrade --user keyring > /dev/null

    pip3 install --user --upgrade pip > /dev/null
    pip3 install --user --upgrade --user pylint pep8 yapf neovim python-vim jedi keyring > /dev/null

    go get -u github.com/alecthomas/gometalinter
    # }}

    # {{ NPM THINGS
    ln -sf $HOME/Dotfiles/rcfiles/eslintrc $HOME/.eslintrc
    ln -sf $HOME/Dotfiles/rcfiles/tern-config $HOME/.tern-config
    ln -sf $HOME/Dotfiles/rcfiles/tern-project $HOME/.tern-project
    npm install -g --upgrade \
        eslint \
        pure \
        eslint-config-google \
        eslint-config-xo \
        tern-jest \
        npm-check \
        tern > /dev/null 2>&1
    # }}

    # {{ SSHRC
    rm -rf $HOME/.sshrc.d
    ln -sf $HOME/Dotfiles/sshrc.d $HOME/.sshrc.d
    ln -sf $HOME/Dotfiles/tools/szinstall.sh $HOME/.sshrc.d/szinstall.sh

    ln -sf $HOME/Dotfiles/rcfiles/sshrc $HOME/.sshrc

    rm -rf sshrc.d/.vimconfig
    ln -sf $HOME/.config/vim sshrc.d/.vimconfig

    mkdir sshrc.d/.vim 2> /dev/null
    rm -rf sshrc.d/.vim/colors 2> /dev/null
    ln -sf $HOME/Dotfiles/vim/colors sshrc.d/.vim/colors
    # }}

    # {{ NCMPCPP
    rm -rf $HOME/.ncmpcpp 2> /dev/null
    mkdir $HOME/.ncmpcpp 2> /dev/null
    ln -sf $HOME/Dotfiles/rcfiles/ncmpcpp $HOME/.ncmpcpp/config
    # }}

    # {{ AWESOME
    rm -r $HOME/.config/awesome 2> /dev/null
    ln -s $HOME/Dotfiles/awesome $HOME/.config/awesome

    ln -sf $HOME/Dotfiles/awesome/rc.$target.lua $HOME/Dotfiles/awesome/rc.lua
    ln -sf $HOME/Dotfiles/rcfiles/xbindkeysrc $HOME/.xbindkeysrc
    # }}

    # {{ COMPTON
    ln -sf $HOME/Dotfiles/rcfiles/compton.conf $HOME/.config/compton.conf
    # }}

    # {{ ICONS AND STUFF
    cp $HOME/Dotfiles/icons/dropbox/*dropbox*.png $HOME/.dropbox-dist/dropbox-lnx.*/images/hicolor/16x16/status/
    ln -sf $HOME/Dotfiles/rcfiles/gtk.css $HOME/.config/gtk-3.0/gtk.css
    ln -s $HOME/Dotfiles/rcfiles/flake8 $HOME/.config/flake8
    # }}
fi
