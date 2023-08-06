#!/usr/bin/env bash

function error() {
	echo "$@" 1>&2
}

function abspath() {
	# From https://stackoverflow.com/a/23002317
	if [ -d "$1" ]; then
		(
			cd "$1"
			pwd
		)
	elif [ -f "$1" ]; then
		if [[ $1 = /* ]]; then
			echo "$1"
		elif [[ $1 == */* ]]; then
			echo "$(
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
	if [ $# -ne 2 ]; then
		echo "Usage: ${FUNCNAME[0]} <var> <string>"
		return 1
	fi
	readarray -t "$1" < <(xargs -n1 <<<"$2")
}

function file_name() {
	if [ $# -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <path>"
		return 1
	fi

	basename -- "$1"
}

function file_label() {
	if [ $# -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <path>"
		return 1
	fi

	local file_name
	file_name="$(file_name "$1")"
	echo "${file_name%.*}"
}

function file_extension() {
	if [ $# -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <path>"
		return 1
	fi

	local file_name
	file_name="$(file_name "$1")"
	echo "${file_name##*.}"
}

function floor() {
	if [ $# -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <number>"
		return 1
	fi

	echo $1 | cut -d . -f 1
}

function ceil() {
	if [ $# -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <number>"
		return 1
	fi

	floored="$(floor $1)"
	echo $((floored + 1))
}

is_blank() {
  local stripped="$(
    echo "$1" | 
    tr -d '[:space:]'
   )"
  if [ -z "$stripped" ]; then
    return 0
  else
    return 1
  fi
}

count() {
    local count=0
    while IFS= read -r line; do
        if ! is_blank "$line" ; then
            count=$((count+1))
        fi
    done
    echo "$count"
}

sum() {
  local sum=0
  while IFS= read -r line; do
    if ! is_blank "$line" ; then
      sum=$(echo "$sum + $line" | bc -l)
    fi
  done
  echo "$sum"
}

mean() {
  local sum=$(sum)
  local count=$(count <<< "$1")
  echo $sum
  echo $count
  
  if [ "$count" -eq 0 ]; then
    error "count is 0"
    return 1
  fi
  
  echo "$(
    echo "$sum / $count" | 
    bc -l
  )"
}

