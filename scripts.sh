#!/usr/bin/env bash

CURRENT_FILE="${BASH_SOURCE[0]}"
SCRIPTS_DIR=$(cd -- "$(dirname -- "$CURRENT_FILE")" &>/dev/null && pwd)

export PATH="$SCRIPTS_DIR/bin:$PATH"
export SHELL_UTILS="$SCRIPTS_DIR/utils"

source "$SHELL_UTILS/utils.sh"
