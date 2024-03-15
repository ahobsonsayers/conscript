#!/usr/bin/env bash
set -euo pipefail # Strict

# Variables
PACKAGE="iopaint"

# Functions
pipx_install() {
  PACKAGE=$1
  shift # Remove the first argument, which is the package name
  EXTRA_PACKAGES=$*

  if ! pipx list -q | grep -qF "$PACKAGE"; then
    echo "$PACKAGE is not installed. Installing."
    pipx install "$PACKAGE"

    if [ -n "$EXTRA_PACKAGES" ]; then
      pipx inject "$PACKAGE" "$EXTRA_PACKAGES"
    fi
  fi

  pipx upgrade "$PACKAGE" -q --include-injected
}

pipx_install "$PACKAGE"

iopaint start \
  --port 1111 \
  --device=mps \
  --enable-interactive-seg \
  --enable-remove-bg \
  "$@"
