#!/bin/bash
set -e

# Use GNU readlink from coreutils
DOT="$(dirname $(greadlink -f ${BASH_SOURCE[0]}))"

if [ ! -d ~/bin ]; then
  mkdir ~/bin
fi

if [ ! -h ~/bin/kbuild ]; then
  ln -s $DOT/kbuild ~/bin/kbuild
fi

if [ -f ~/.zshrc ]; then
  TARGET_PROFILE=~/.zshrc
else
  TARGET_PROFILE=~/.profile
fi

# Add ~/bin to path
SET_PATH="export PATH=\"\$PATH:\$HOME/bin\""
if cat $TARGET_PROFILE | grep -q "^$SET_PATH\$"; then
  echo "PATH already set"
else
  echo "Setting PATH"
  echo $SET_PATH >> $TARGET_PROFILE
fi

