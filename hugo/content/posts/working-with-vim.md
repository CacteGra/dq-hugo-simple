---
title: "Vim customisation with colour palettes"
date: 2025-08-20
draft: false
tags: ["dev", "vim"]
categories: ["tutorials"]
description: "Learn how to use plugins to change Vim colour scheme."
---
Vim is a text editor whose particularity resides in customisation with each and every programmer able to add rich features to suit their programmer needs. Thus when one starts their journey learning Vim, tailoring the editor's colours for high readability is first, a way to learn how to use it, but also a way to start forging Vim into the right tool for the job.

## Prepping for colours
Your system should have **Vim** installed by default, however to use the option to change its colours you need to install **vim-enhanced** package, on Fedora:
  `sudo dnf install vim-enhanced`
  Another solution is to install **Neovim** which has everything need plus other features.


You can already choose your theme among the few your Vim install already has. To do so, we will open vim and choose a theme:
  `vi`
  Press *:* and add the following:
  `colorscheme `
  Now press *Tab* to rotate between available themes and press *Enter* to select one.


Default colours are pretty but we want more. 

## Customising Vim
Let's create the necessary files and folders to customise our Vim:
  ```bash
  mkdir ~/.vim
  mkdir ~/.vim/colors
  mkdir ~/.vim/bundle
  touch ~/.vimrc
  ```


Inside the folder *~/.vim/colors* you can create your very own *colour_scheme.vim* file in order to add your palette when working on files with Vim.

## Using plugins for easy customisation
**.vimrc** is Vim's configuration file. Inside we will set our customisation.
  For this example, we are going to install two plugins.
  The first one, *Vundle*, is a plugin manager and will help us install and manage our colour plugin, *PaperColor*.


Clone Vundle repository:
  `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`


`vi ~/.vimrc`
  Press *i* to start editing the file, and paste the following configuration:
  
  ```vim
  set nocompatible              " be iMproved, required
  filetype off                  " required
  
  " set the runtime path to include Vundle and initialize
  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
  " alternatively, pass a path where Vundle should install plugins
  "call vundle#begin('~/some/path/here')
  
  " let Vundle manage Vundle, required
  Plugin 'VundleVim/Vundle.vim'
  
  " All of your Plugins must be added before the following line
  
  call vundle#end()            " required
  filetype plugin indent on    " required
  " To ignore plugin indent changes, instead use:
  "filetype plugin on
  "
  " Brief help
  " :PluginList       - lists configured plugins
  " :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
  " :PluginSearch foo - searches for foo; append `!` to refresh local cache
  " :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
  "
  " see :h vundle for more details or wiki for FAQ
  " Put your non-Plugin stuff after this line
  ```
  Press *Esc* to be able to add commands, and then *:* followed by *wq* to write the file and quit Vim.
- A few useful commands here to start your journey with Vim:
	- *i* for editing.
	- *Esc* key gets you back to entering commands.
	- *:w* to write the file and *:q* to quit Vim.
	- *:q!* if your need to quit editing the file without saving changes.
	- *dd* will delete current line. Add a number before to delete lines starting from your cursor down: *num* then *dd*.


As explained in the example, `" All of your Plugins must be added before the following line`.
  That is where you need to add the following:
  `Plugin 'NLKNguyen/papercolor-theme'`
  Now let Vim install the plugin by running:
  `vim +PluginInstall +qall`

## Leaving the work to Vundle
We are now set to install other colour schemes.
  Again, below the line " All of your Plugins must be added before the following line, add the line to install the plugin:
  `Plugin 'NLKNguyen/papercolor-theme'`
  And run the command for Vim to install this new plugin:
  `vim +PluginInstall +qall`
  Go back to *~/.vimrc* and at the end of the file add the following to set our colour theme to PaperColor:
  ```vim
  colorscheme PaperColor
  set background=dark
  ```


If colours do not look right, as in displayed colour scheme is not what you saw on the example, write this at the end of the *.vimrc* file:
  ```vim
  if has("termguicolors")
    set termguicolors
    if &t_8f == ''
      " The first characters after the equals sign are literal escape characters.
      set t_8f=[38;2;%lu;%lu;%lum
      set t_8b=[48;2;%lu;%lu;%lum
    endif
  endif
  ```
  
## Make Vim look right to you
That's it, you now know how to customise your vim and make it as your own so it is easier for the eyes and for your code.

Try and have a look at [vimcolorschemes](https://vimcolorschemes.com/i/trending) for more colouring schemes.