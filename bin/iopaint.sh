#!/usr/bin/env bash
set -euo pipefail # Strict

# Variables
PACKAGE="iopaint"

# Functions
pipx_install() {
  PACKAGE=$1
  shift # Remove the first argument, which is the package name
  EXTRA_PACKAGES=$*

  # Install main package
  if ! pipx list -q | grep -qF "$PACKAGE"; then
    echo "$PACKAGE is not installed. Installing."
    pipx install "$PACKAGE"
  fi

  # Get currently installed packages
  INSTALLED_PACKAGES="$(pipx runpip iopaint list)"

  # Find missing extra packages
  MISSING_EXTRA_PACKAGES=""
  for EXTRA_PACKAGE in "${EXTRA_PACKAGES[@]}"; do
    if ! echo "$INSTALLED_PACKAGES" | grep -q "^${EXTRA_PACKAGE}\s"; then
      MISSING_EXTRA_PACKAGES="$MISSING_EXTRA_PACKAGES $EXTRA_PACKAGE"
    fi
  done

  # Inject missing packages
  if [ -n "$MISSING_EXTRA_PACKAGES" ]; then
    pipx inject iopaint "$MISSING_EXTRA_PACKAGES"
  fi

  # Upgrade all packages
  pipx upgrade "$PACKAGE" -q --include-injected
}

pipx_install "$PACKAGE" rembg

iopaint start \
  --port 1111 \
  --inbrowser \
  --device=mps \
  --enable-interactive-seg \
  --enable-remove-bg \
  --model timbrooks/instruct-pix2pix \
  --model-dir ~/models \
  "$@"
