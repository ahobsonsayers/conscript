#!/usr/bin/env bash
set -euo pipefail # Strict

# Variables
NAME="Lama Cleaner"
PACKAGE="lama-cleaner"

# Install if required
if ! pipx list | grep -qF "$PACKAGE"; then
  echo "$NAME is not installed. Installing."
  pipx install "$PACKAGE"

  # Inject additional packages
  pipx inject "$PACKAGE" accelerate rembg
fi

pipx upgrade "$PACKAGE" --include-injected

lama-cleaner \
  --port 1111 \
  --device=mps \
  --model-dir ~/models \
  --enable-interactive-seg \
  --enable-remove-bg \
  "$@"
