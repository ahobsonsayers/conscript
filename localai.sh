#!/usr/bin/env bash
set -euo pipefail # Strict

# Variables
NAME="LocalAI"
REPO="https://github.com/go-skynet/LocalAI"
DIR="$HOME/localai"

# Clone repo if required
if [[ ! -d "$DIR" ]]; then
    echo "$NAME is not installed. Installing."
    git clone "$REPO" "$DIR" --depth 1
fi

cd "$DIR"

# Checkout latest tag
git fetch --tags
tagHash=$(git rev-list --tags --max-count=1)
tagName=$(git describe --tags "$tagHash")
git checkout "$tagName"

# If updated
checkout_status=$?
if [[ checkout_status -eq 0 ]]; then
    echo "Updated to $tagName. Building"
    make BUILD_TYPE=metal build
fi

./local-ai --f16 --autoload-galleries --address :1111 "$@"
