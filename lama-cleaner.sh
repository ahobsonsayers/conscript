#!/usr/bin/env bash
set -euo pipefail # Strict

# Variables
NAME="Lama Cleaner"
PACKAGE="lama-cleaner"

# Install if required
if ! pipx list | grep -qF "$PACKAGE"; then
    echo "$NAME is not installed. Installing."
    pipx install "$PACKAGE"
fi

pipx upgrade "$PACKAGE"

lama-cleaner
