#! /bin/bash

mkdir ~/Tools 2> /dev/null
cd ~/Tools

git clone https://github.com/dflupu/base16-shell.git
git clone https://github.com/junegunn/fzf.git
git clone https://github.com/dflupu/sshrc
git clone https://github.com/rupa/z.git

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

yarn global add diff-so-fancy

ln -s $HOME/dotfiles/tools/load_fzf.sh fzf/load.sh
