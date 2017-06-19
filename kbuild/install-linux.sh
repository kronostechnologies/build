#!/bin/bash
set -e

DOT="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"

if ! command -v kbuild >/dev/null 2>&1; then
  if [ "`id -u`" -eq 0 ]; then
    ln -nsf $DOT/kbuild /usr/local/bin/
  else
    mkdir -p ~/bin
    ln -nsf $DOT/kbuild ~/bin/
  fi
fi
