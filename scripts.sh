#!/usr/bin/env bash
# shellcheck disable=SC1090

CURRENT_FILE="${BASH_SOURCE[0]}"
SCRIPTS_DIR=$(cd -- "$(dirname -- "$CURRENT_FILE")" &>/dev/null && pwd)

export PATH="$SCRIPTS_DIR/bin:$PATH"
export BASH_UTILS="$SCRIPTS_DIR/utils"

source "$BASH_UTILS/utils.sh"
