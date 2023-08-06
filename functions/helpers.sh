#!/usr/bin/env bash

function error() {
	echo "$@" 1>&2
}

function abspath() {
	# From https://stackoverflow.com/a/23002317
	if [ -d "$1" ]; then
		(
			# shellcheck disable=SC2164
			cd "$1"
			pwd
		)
	elif [ -f "$1" ]; then
		if [[ $1 = /* ]]; then
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
	if [ $# -ne 2 ]; then
		echo "Usage: ${FUNCNAME[0]} <var> <string>"
		return 1
	fi
	readarray -t "$1" < <(xargs -n1 <<<"$2")
}

function array_parse_lines() {
	if [ $# -ne 1 ]; then
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

	cut -d . -f 1 <<<"$1"
}

function ceil() {
	if [ $# -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <number>"
		return 1
	fi

	floored="$(floor "$1")"
	echo $((floored + 1))
}

function error() {
	echo "$@" 1>&2
}

is_blank() {
	local stripped
	stripped="$(tr -d '[:space:]' <<<"$1")"

	if [ -z "$stripped" ]; then
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

sum() {
	local sum=0
	while IFS= read -r line; do
		if ! is_blank "$line"; then
			sum=$(bc -l <<<"$sum + $line")
		fi
	done
	echo "$sum"
}

mean() {
	local input
	input="$(cat)"

	local sum_result
	sum_result=$(sum <<<"$input")

	local count_result
	count_result=$(count <<<"$input")
	if [ "$count_result" -eq 0 ]; then
		error "count is 0"
		return 1
	fi

	bc -l <<<"$sum_result / $count_result"
}

median() {
	local input
	input="$(cat)"

	# Read numbers into an array
	local num_array
	array_parse_lines num_array <<<"$input"

	# Sort numbers
	local sorted_num_array
	readarray -t sorted_num_array < <(printf "%s\n" "${num_array[@]}" | sort -n)

	local count_result
	count_result=$(count <<<"$input")
	if [ "$count_result" -eq 0 ]; then
		error "count is 0"
		return 1
	fi

	# Calculate median
	local idx=$((count / 2))
	local mid_num=${sorted_num_array[idx1]}

	if [ $((count % 2)) -ne 0 ]; then
		local idx2=$((idx + 1))
		local mid_num2=${sorted_num_array[idx2]}
		bc -l <<<"($mid_num + $mid_num2) / 2"
	else
		echo "$mid_num"
	fi
}
