#!/usr/bin/env bash
# set -euo pipefail

# brew
# sd
# calc
# st
# ffmpeg

function install_peaqb() {
  git clone https://github.com/akinori-ito/peaqb-fast
  cd peaqb-fast || return 1
  ./configure
  make
  cp -f ./src/peaqb ~/.local/bin
  cd ..
  rm -rf peaqb-fast
}
