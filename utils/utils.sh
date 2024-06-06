#!/usr/bin/env bash
# shellcheck disable=SC1090

if [ -z "$SHELL_UTILS" ]; then
  printf "%s\n" "Error: Shell utils directory is not set. Please set \$SHELL_UTILS before sourcing this file." >&2
  return 1
fi

for file in "$SHELL_UTILS"/*.sh; do
  if [[ -r $file && $file != "$SHELL_UTILS"/utils.sh ]]; then
    source "$file"
  fi
done
