#!/usr/bin/env bash

# Get media duration
function media_duration {
  check_cmds mediainfo

  if ! {
    [[ $# == 1 ]] ||
      [[ $# == 2 && $1 =~ ^("general"|"video"|"audio")$ ]]
  }; then
    echo "Usage: ${FUNCNAME[0]} [type] <input>"
    echo "<type> must be one of: general, video, audio"
    return 1
  fi

  local type="$1"
  local file="$2"

  if [[ $# -eq 1 ]]; then
    type="general"
    file="$1"
  fi

  mediainfo \
    --Output="${type^};%Duration/String3%" \
    "$file"
}

# Get media duration (in seconds)
function media_duration_seconds {
  check_cmds mediainfo

  if ! {
    [[ $# == 1 ]] ||
      [[ $# == 2 && $1 =~ ^("general"|"video"|"audio")$ ]]
  }; then
    echo "Usage: ${FUNCNAME[0]} [type] <input>"
    echo "[type] must be one of: general, video, audio"
    return 1
  fi

  local type="$1"
  local file="$2"

  if [[ $# -eq 1 ]]; then
    type="general"
    file="$1"
  fi

  local duration_ms
  duration_ms="$(
    mediainfo \
      --Output="${type^};%Duration%" \
      "$file"
  )"

  bc <<<"scale=3; $duration_ms / 1000"
}
