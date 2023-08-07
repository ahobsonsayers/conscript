#!/usr/bin/env bash

# Get video quality metrics
# Requires ffmpeg-quality-metrics
# https://github.com/slhck/ffmpeg-quality-metrics
# pipx install ffmpeg-quality-metrics
function video_quality() {
  if [ $# -ne 2 ]; then
    echo "Usage: ${FUNCNAME[0]} <source> <target>"
    return 1
  fi

  local output_directory
  local output_label
  local output_path

  output_directory="$(dirname "$2")"
  output_label="$(file_label "$2")"
  output_path="${output_directory}/${output_label}.json"

  ffmpeg-quality-metrics "$2" "$1" \
    -s lanczos \
    -m vmaf ssim psnr |
    jq '.global | {
        vmaf: .vmaf.vmaf, 
        ssim: .ssim.ssim_avg, 
        psnr: .psnr.psnr_avg, 
        mse: .psnr.mse_avg 
      }' \
      >"$output_path"
}

function audio_quality() {
  if [ $# -ne 2 ]; then
    echo "Usage: ${FUNCNAME[0]} <source> <target>"
    return 1
  fi

  local output_directory
  local output_label
  local output_path

  output_directory="$(dirname "$2")"
  output_label="$(file_label "$2")"
  output_path="${output_directory}/${output_label}.json"

  local results
  results="$(
    peaqb \
      -r "$1" \
      -t "$2" |
      grep "ODG:" |
      cut -d " " -f 2
  )" || return 1

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
    >"$output_path"
}
