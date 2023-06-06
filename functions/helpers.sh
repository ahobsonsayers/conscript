#!/bin/bash

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
	mapfile -t "$1" < <(xargs -n1 <<<"$2")
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

	file_name="$(file_name "$1")"
	echo "${file_name%.*}"
}

function file_extension() {
	if [ $# -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <path>"
		return 1
	fi

	file_name="$(file_name "$1")"
	echo "${file_name##*.}"
}
