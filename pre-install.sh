#!/bin/bash

# Copied from https://github.com/iraquitan/iraquitan-dotfiles/blob/master/pre-install.sh

# Check if Homebrew is installed
if [ ! -f "`which brew`" ]; then
  echo 'Homebrew not installed, installing now'
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo 'You have Homebrew! Running Update now 🍻'
  brew update
fi
brew tap homebrew/bundle  # Install Homebrew Bundle

# Check if oh-my-zsh is installed
OMZDIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZDIR" ]; then
  echo 'oh-my-zsh not installed, installing now'
  /bin/sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
  echo 'Running update for oh-my-zsh'
  upgrade_oh_my_zsh
fi

# Check if ~/.oh-my-zsh/themes/powerlevel10k exists
if [ ! -d "$OMZDIR/themes/powerlevel10k" ]; then
  echo 'Installing powerlevel10k theme'
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$OMZDIR/themes/powerlevel10k"
else
  echo 'powerlevel10k theme already installed'
fi

# Check if Mac-CLI is installed
if [ ! -f "which mac" ]; then
    echo 'Installing Mac-CLI'
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/guarinogabriel/mac-cli/master/mac-cli/tools/install)"
else
    echo 'Mac-CLI detected, updating now'
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/guarinogabriel/mac-cli/master/mac-cli/tools/update)"
fi

# Change default shell
if [ ! $0 = "-zsh" ]; then
  echo 'Changing default shell to zsh'
  chsh -s /bin/zsh
else
  echo 'Already using zsh'
fi