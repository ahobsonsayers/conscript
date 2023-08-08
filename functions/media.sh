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

  local output_dir
  local output_label
  local output_json

  output_dir="$(dirname "$2")"
  output_label="$(file_label "$2")"
  output_json="${output_dir}/${output_label}.json"

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
  if [ $# -ne 2 ]; then
    echo "Usage: ${FUNCNAME[0]} <source> <target>"
    return 1
  fi

  local source_dir
  local source_label
  local source_wav
  source_dir="$(dirname "$1")"
  source_label="$(file_label "$1")"
  source_wav="${source_dir}/${source_label}.wav"

  local target_dir
  local target_label
  local target_wav
  target_dir="$(dirname "$2")"
  target_label="$(file_label "$2")"
  target_wav="${target_dir}/${target_label}.wav"

  local output_json
  output_json="${target_dir}/${target_label}.json"

  # Convert source and target audio to wav (if required)
  if [ ! -f "$source_wav" ]; then
    echo "Converting source audio to wav"
    ffmpeg \
      -hide_banner -v warning \
      -nostdin -stats \
      -i "$1" \
      -map a:0 \
      -codec:a pcm_s16le \
      -ac 2 \
      -ar 48000 \
      "$source_wav" || return 1
    echo
  fi

  if [ ! -f "$target_wav" ]; then
    echo "Converting target audio to wav"
    ffmpeg \
      -hide_banner -v warning \
      -nostdin -stats \
      -i "$2" \
      -map a:0 \
      -codec:a pcm_s16le \
      -ac 2 \
      -ar 48000 \
      "$target_wav" || return 1
    echo
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

  if [ -z "$results" ]; then
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

function audio_difference() {
  if [ $# -ne 2 ]; then
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
  local delay
  filename="$(cut -d " " -f 1 <<<"$result")"
  delay="$(cut -d " " -f 2 <<<"$result")"

  printf "%s %.6f\n" "$filename" "$delay"
}
