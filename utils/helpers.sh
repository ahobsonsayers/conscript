#!/usr/bin/env bash

function abspath() {
  # From https://stackoverflow.com/a/23002317
  if [[ -d $1 ]]; then
    (
      # shellcheck disable=SC2164
      cd "$1"
      pwd
    )
  elif [[ -f $1 ]]; then
    if [[ $1 == /* ]]; then
      echo "$1"
    elif [[ $1 == */* ]]; then
      echo "$(
        # shellcheck disable=SC2164
        cd "${1%/*}"
        pwd
      )/${1##*/}"
    else
      echo "$(pwd)/$1"
    fi
  else
    echo "Invalid path" 1>&2
    return 1
  fi
}

function file_name() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <path>"
    return 1
  fi

  basename -- "$1"
}

function file_label() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <path>"
    return 1
  fi

  local file_name
  file_name="$(file_name "$1")"
  echo "${file_name%.*}"
}

function file_extension() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <path>"
    return 1
  fi

  local file_name
  file_name="$(file_name "$1")"
  echo "${file_name##*.}"
}

function check_installed() {
  local missing=()
  for cmd in "$@"; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -ne 0 ]; then
    echo "The following are not installed: ${missing[*]}"
    return 1
  fi
}
