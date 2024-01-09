#!/usr/bin/env bash

function error() {
    echo -e "\e[31m$*\e[0m" 1>&2
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
