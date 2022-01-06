#!/bin/sh

set -xe

# Vim
mkdir -p ~/.vim/syntax &&
cp irida.vim ~/.vim/syntax/irida.vim &&

# Neovim
mkdir -p ~/.config/nvim/syntax &&
cp irida.vim ~/.config/nvim/syntax/irida.vim &&

echo "autocmd BufRead,BufNewFile *.iri set filetype=irida" | tee -a '~/.vimrc'