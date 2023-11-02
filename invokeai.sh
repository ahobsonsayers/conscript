#!/usr/bin/env bash
set -euo pipefail # Strict

# Variables
NAME="InvokeAI"
REPO="invoke-ai/InvokeAI"
DIR="$HOME/invokeai"

# Install if required
if [[ ! -d $DIR ]]; then
  echo "$NAME is not installed. Installing."

  INSTALLER_DIR="/tmp/invokeai"
  INSTALLER_ZIP="$INSTALLER_DIR/installer.zip"

  mkdir -p "$INSTALLER_DIR"

  # Download latest installer zip
  latest_release=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
  latest_installer=$(echo "$latest_release" | grep -o 'https://github.com[^"]*installer[^"]*.zip')
  wget -O "$INSTALLER_ZIP" "$latest_installer"

  # Unzip and install
  unzip -o -d "$INSTALLER_DIR" "$INSTALLER_ZIP"
  "$INSTALLER_DIR/InvokeAI-Installer/install.sh" -y

  # Cleanup
  rm -rf "$INSTALLER_DIR"
fi

cd "$DIR"

# Run
./invoke.sh
