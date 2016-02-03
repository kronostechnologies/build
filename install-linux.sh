#!/bin/bash
set -e

DOT="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"

if [ ! -h /usr/local/bin/kbuild ]
then
  ln -s $DOT/kbuild /usr/local/bin/kbuild
fi
