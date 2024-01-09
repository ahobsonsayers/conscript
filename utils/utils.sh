#!/usr/bin/env bash
# shellcheck disable=SC1090

CURRENT_FILE="${BASH_SOURCE[0]}"
BASH_UTILS=$(cd -- "$(dirname -- "$CURRENT_FILE")" &>/dev/null && pwd)

for file in "$BASH_UTILS"/*.sh; do
  if [[ $file != "$CURRENT_FILE" && -r $file ]]; then
    source "$file"
  fi
done
