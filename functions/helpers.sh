#!/usr/bin/env bash

function error() {
  echo -e "\e[31m$*\e[0m" 1>&2
}

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

function array_parse() {
  # From https://stackoverflow.com/a/61474683
  if [[ $# -ne 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <var> <string>"
    return 1
  fi
  readarray -t "$1" < <(xargs -n1 <<<"$2")
}

function array_parse_lines() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <var> [strings...]"
    return 1
  fi

  local -n array="$1" # -n declares the variable is a reference

  while IFS= read -r line; do
    if ! is_blank "$line"; then
      array+=("$line")
    fi
  done
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

is_blank() {
  local stripped
  stripped="$(tr -d '[:space:]' <<<"$1")"

  if [[ -z $stripped ]]; then
    return 0
  else
    return 1
  fi
}

count() {
  local count=0
  while IFS= read -r line; do
    if ! is_blank "$line"; then
      count=$((count + 1))
    fi
  done

  echo "$count"
}
