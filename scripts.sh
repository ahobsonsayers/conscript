#!/usr/bin/env bash
# shellcheck disable=SC1090

SCRIPTS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# scripts
export PATH="$SCRIPTS_DIR/bin:$PATH"

# functions
for function in "$SCRIPTS_DIR/functions/"*; do
  [[ -r $function ]] &&
    source "$function"
done
