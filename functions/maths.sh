#!/usr/bin/env bash

calc() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <expression>"
    return 1
  fi

  awk "BEGIN { print $1 }"
}

function floor() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <number>"
    return 1
  fi

  cut -d . -f 1 <<<"$1"
}

function ceil() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <number>"
    return 1
  fi

  floored="$(floor "$1")"
  calc "$floored + 1"
}

min() {
  # Use first num as the initial max
  local min_value
  while IFS= read -r num; do
    if ! is_blank "$num" && {
      [[ -z $min_value ]] ||
        [[ "$(calc "$num < $min_value")" -eq 1 ]]
    }; then
      min_value="$num"
    fi
  done

  echo "$min_value"
}

max() {
  # Use first num as the initial max
  local max_value
  while IFS= read -r num; do
    if ! is_blank "$num" && {
      [[ -z $max_value ]] ||
        [[ "$(calc "$num > $max_value")" -eq 1 ]]
    }; then
      max_value="$num"
    fi
  done

  echo "$max_value"
}

max() {
  local max_value

  while IFS= read -r line; do
    while IFS=$'\t , ' read -r -a numbers; do
      for num in "${numbers[@]}"; do
        if ! is_blank "$num" && {
      [[ -z $max_value ]] ||
        [[ "$(calc "$num > $max_value")" -eq 1 ]]
    }; then
      max_value="$num"
    fi
      done
    done <<< "$line"
  done

  echo "$max_value"
}

sum() {
  local sum=0
  while IFS= read -r num; do
    if ! is_blank "$num"; then
      sum=$(calc "$sum + $num")
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

  if [[ $count_result -eq 0 ]]; then
    error "count is 0"
    return 1
  fi

  calc "$sum_result / $count_result"
}

median() {
  local input
  input="$(cat)"

  local count_result
  count_result=$(count <<<"$input")

  if [[ $count_result -eq 0 ]]; then
    error "count is 0"
    return 1
  fi

  # Read numbers into an array
  local num_array
  array_parse_lines num_array <<<"$input"

  # Sort numbers
  local sorted_num_array
  readarray -t sorted_num_array < <(printf "%s\n" "${num_array[@]}" | sort -n)

  # Calculate median
  local idx=$((count_result / 2))
  local mid_num=${sorted_num_array[idx]}

  if [[ $((count_result % 2)) -eq 0 ]]; then
    local idx2=$((idx - 1))
    local mid_num2=${sorted_num_array[idx2]}
    calc "($mid_num + $mid_num2) / 2"
  else
    echo "$mid_num"
  fi
}
