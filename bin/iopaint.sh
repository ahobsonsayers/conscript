#!/usr/bin/env bash
set -euo pipefail # Strict

# Variables
PACKAGE="iopaint"

# Functions
pipx_install() {
  PACKAGE=$1
  shift # Remove the first argument, which is the package name
  EXTRA_PACKAGES=("$@")

  # Install main package
  if ! pipx list -q | grep -qF "$PACKAGE"; then
    echo "$PACKAGE is not installed. Installing."
    pipx install "$PACKAGE"
  fi

  # Get currently installed packages
  INSTALLED_PACKAGES="$(pipx runpip "$PACKAGE" list)"

  # Find missing extra packages
  MISSING_EXTRA_PACKAGES=()
  for EXTRA_PACKAGE in "${EXTRA_PACKAGES[@]}"; do
    if ! echo "$INSTALLED_PACKAGES" | grep -q "^${EXTRA_PACKAGE}\s"; then
      MISSING_EXTRA_PACKAGES+=("$EXTRA_PACKAGE")
    fi
  done

  # Inject missing packages
  if [ ${#MISSING_EXTRA_PACKAGES[@]} -ne 0 ]; then
    pipx inject "$PACKAGE" "${MISSING_EXTRA_PACKAGES[@]}"
  fi

  # Upgrade all packages
  pipx upgrade "$PACKAGE" -q --include-injected
}

pipx_install "$PACKAGE" gfpgan realesrgan rembg

iopaint start \
  --port 1111 \
  --inbrowser \
  --device mps \
  --model lama \
  --model-dir ~/models \
  --enable-interactive-seg \
  --interactive-seg-device mps \
  --enable-remove-bg \
  --enable-realesrgan \
  --realesrgan-device mps \
  --enable-gfpgan \
  --gfpgan-device mps \
  --enable-restoreformer \
  --restoreformer-device mps \
  --disable-nsfw-checker \
  "$@"
