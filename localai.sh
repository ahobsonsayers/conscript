#!/usr/bin/env bash
set -euo pipefail # Strict

function error() {
    echo -e "\e[31m$*\e[0m" 1>&2
}

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

if [[ "$#" -eq 1 && "$1" = "models" ]]; then
    curl -s http://localhost:1111/v1/models | jq . || error "LocalAI is not running"
    exit
fi

./local-ai \
    --address :1111 \
    --models-path "$HOME/models/llm" \
    --autoload-galleries \
    "$@"
