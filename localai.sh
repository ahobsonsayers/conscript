#!/usr/bin/env bash
set -euo pipefail # Strict

# Variables
REPO_URL="https://github.com/go-skynet/LocalAI.git"
DIR="$HOME/localai"

# Clone repo if required
if [[ ! -d "$DIR" ]]; then
    echo "$DIR does not exist. Cloning LocalAI."
    git clone "$REPO_URL" "$DIR" --depth 1
fi

cd "$DIR"

# Checkout latest tag
git fetch --tags
tagHash=$(git rev-list --tags --max-count=1)
tagName=$(git describe --tags "$tagHash")
git checkout "$tagName" || true

# If updated
checkout_status=$?
if [[ checkout_status -eq 0 ]]; then
    echo "Updated to $tagName. Building"
    make BUILD_TYPE=metal build
fi
