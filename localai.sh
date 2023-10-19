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

# Get latest tag
git fetch --tags
latestTagHash=$(git rev-list --tags --max-count=1)
currentTag=$(git describe --tags)
newTag=$(git describe --tags "$latestTagHash")

# If updated
if [[ "$currentTag" != "$newTag" ]]; then
    git checkout "$newTag"
    echo "Updated to $newTag. Building"
    make BUILD_TYPE=metal build
fi

./local-ai --f16 --autoload-galleries --address :1111 "$@"
