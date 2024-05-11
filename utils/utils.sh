#!/usr/bin/env bash
# shellcheck disable=SC1090

CURRENT_FILE="${BASH_SOURCE[0]}"
SHELL_UTILS=$(cd -- "$(dirname -- "$CURRENT_FILE")" &>/dev/null && pwd)

for file in "$SHELL_UTILS"/*.sh; do
  if [[ $file != "$CURRENT_FILE" && -r $file ]]; then
    source "$file"
  fi
done
