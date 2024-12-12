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

pipx_install "$PACKAGE" gfpgan onnxruntime realesrgan rembg

iopaint start \
  --port 1111 \
  --inbrowser \
  --model-dir ~/.cache \
  --model lama \
  --disable-nsfw-checker \
  --enable-interactive-seg \
  --enable-remove-bg \
  --enable-realesrgan \
  --enable-gfpgan \
  --enable-restoreformer \
  --remove-bg-model briaai/RMBG-2.0 \
  --device mps \
  --interactive-seg-device mps \
  --remove-bg-device mps \
  --realesrgan-device mps \
  --gfpgan-device mps \
  --restoreformer-device mps \
  "$@"
