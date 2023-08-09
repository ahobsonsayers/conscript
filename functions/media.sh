#!/usr/bin/env bash

# Get video quality metrics
# Requires ffmpeg-quality-metrics
# https://github.com/slhck/ffmpeg-quality-metrics
# pipx install ffmpeg-quality-metrics
function video_quality() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <source> <target>"
    return 1
  fi

  local output_dir
  output_dir="$(dirname "$2")"

  local output_label
  output_label="$(file_label "$2")"

  local output_json="${output_dir}/${output_label}.json"

  echo "Measuring video quality"
  ffmpeg-quality-metrics "$2" "$1" \
    -s lanczos \
    -m vmaf ssim psnr |
    jq '.global | {
        vmaf: .vmaf.vmaf, 
        ssim: .ssim.ssim_avg, 
        psnr: .psnr.psnr_avg, 
        mse: .psnr.mse_avg 
      }' \
      >"$output_json"

  echo "Written results to $output_json"
}

function audio_quality() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <source> <target>"
    return 1
  fi

  local source_dir
  local target_dir
  source_dir="$(dirname "$1")"
  target_dir="$(dirname "$2")"

  local source_label
  local target_label
  source_label="$(file_label "$1")"
  target_label="$(file_label "$2")"

  local source_wav="${source_dir}/${source_label}.wav"
  local target_wav="${target_dir}/${target_label}.wav"
  local output_json="${target_dir}/${target_label}.json"

  # Convert source and target audio to wav (if required)
  if [[ ! -f $source_wav ]]; then
    echo "Converting $1 audio to wav"
    ffmpeg \
      -hide_banner -v warning \
      -nostdin -stats \
      -i "$1" \
      -map a:0 \
      -codec:a pcm_s16le \
      -ac 2 \
      -ar 48000 \
      "$source_wav" ||
      return 1
    echo
  fi

  if [[ ! -f $target_wav ]]; then
    echo "Converting $2 audio to wav"
    ffmpeg \
      -hide_banner -v warning \
      -nostdin -stats \
      -i "$2" \
      -map a:0 \
      -codec:a pcm_s16le \
      -ac 2 \
      -ar 48000 \
      "$target_wav" ||
      return 1
    echo
  fi

  # Check if files are out of sync
  local diff_result
  local diff_file
  local diff_time
  diff_result="$(audio_diff "$source_wav" "$target_wav")"
  diff_file="$(cut -d " " -f 1 <<<"$diff_result")"
  diff_time="$(cut -d " " -f 2 <<<"$diff_result")"

  # Sync files if required
  if [[ $diff_time != 0 ]]; then

    local diff_dir
    diff_dir="$(dirname "$diff_file")"

    local diff_label
    diff_label="$(file_label "$diff_file")"

    local sync_file="${diff_dir}/sync-${diff_label}.wav"

    echo "Trimming $diff_file by ${diff_time}s to sync audio"
    ffmpeg \
      -hide_banner -v warning \
      -nostdin -stats \
      -i "$diff_file" \
      -ss "$diff_time" \
      "$sync_file" ||
      return 1
    echo

    mv "$sync_file" "$diff_file"
  fi

  echo "Measuring audio quality"
  local results
  results="$(
    peaqb \
      -r "$source_wav" \
      -t "$target_wav" |
      grep "ODG:" |
      cut -d " " -f 2
  )"
  if [[ -z $results ]]; then
    return 1
  fi

  local mean
  local median
  local stddev
  local min
  local max

  mean="$(st -q --mean <<<"$results")"
  median="$(st -q --median <<<"$results")"
  stddev="$(st -q --stddev <<<"$results")"
  min="$(st -q --min <<<"$results")"
  max="$(st -q --max <<<"$results")"

  jq -n \
    --argjson mean "$mean" \
    --argjson median "$median" \
    --argjson stddev "$stddev" \
    --argjson min "$min" \
    --argjson max "$max" \
    '{
      "mean": $mean,
      "median": $median,
      "stddev": $stddev,
      "min": $min,
      "max": $max
    }' \
    >"$output_json"

  echo "Written results to $output_json"
}

function audio_diff() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <source> <target>"
    return 1
  fi

  local result
  result="$(
    syncstart "$1" "$2" -st 120 \
      2>&1 |
      tail -n 1 |
      sed "s|[\(\)',]||g"
  )"

  local filename
  local time
  filename="$(cut -d " " -f 1 <<<"$result")"
  time="$(cut -d " " -f 2 <<<"$result")"

  printf "%s %g\n" "$filename" "$time"
}
