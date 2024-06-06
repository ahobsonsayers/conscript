# shellcheck shell=bash
# shellcheck disable=SC1007,SC1091

# Based on https://github.com/asdf-vm/asdf/blob/master/asdf.sh
# See that file for help on how this works

# This file is the entrypoint for all POSIX-compatible shells. If `SCRIPTS_DIR` is
# not already set, this script is able to calculate it, but only if the shell is
# either Bash, Zsh, and Ksh. For other shells, `SCRIPTS_DIR` must be manually set.

export SCRIPTS_DIR="${SCRIPTS_DIR:-}"

if [ -z "$SCRIPTS_DIR" ]; then

  if [ -n "${BASH_VERSION:-}" ]; then
    CURRENT_FILE="${BASH_SOURCE[0]}"

  elif [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC2296
    CURRENT_FILE=${(%):-%x}
  fi

  SCRIPTS_DIR=$(cd -- "$(dirname -- "$CURRENT_FILE")" &>/dev/null && pwd)

fi

if [ -z "$SCRIPTS_DIR" ]; then
  printf "%s\n" "Error: Cannot determine \$SCRIPTS_DIR. Please set \$SCRIPTS_DIR manually before sourcing this file." >&2
  return 1
fi

if [ ! -d "$SCRIPTS_DIR" ]; then
  printf "%s\n" "Error: Variable '\$SCRIPTS_DIR' is not a directory: $SCRIPTS_DIR" >&2
  return 1
fi

function prefixpath() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}

function suffixpath() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+":$PATH"}"
  fi
}

prefixpath "$SCRIPTS_DIR/bin"

export SHELL_UTILS="$SCRIPTS_DIR/utils"

source "$SHELL_UTILS/utils.sh"
