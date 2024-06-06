#!/usr/bin/env bash

function video_duration {
  media_duration video "$@"
}

function video_duration_seconds {
  media_duration_seconds video "$@"
}

# Get video quality metrics
# Requires ffmpeg-quality-metrics
# https://github.com/slhck/ffmpeg-quality-metrics
# pipx install ffmpeg-quality-metrics
function video_quality {
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
    --progress \
    -s spline \
    -t 4 \
    -m vmaf >"$output_json"

  # ffmpeg-quality-metrics "$2" "$1" \
  #   --progress \
  #   -s spline \
  #   -t 4 \
  #   -m vmaf ssim psnr \
  #   --vmaf-features float_ms_ssim psnr_hvs |
  #   jq '.global | {
  #      ssim: .ssim.ssim_avg
  #      psnr: .psnr.psnr_avg
  #      vmaf: .vmaf.vmaf,
  #      ssim: .vmaf.float_ms_ssim,
  #      psnr: .vmaf.psnr_hvs
  #   }' >"$output_json"

  echo "Written results to $output_json"
}

function video_crop_lossless {
  check_installed ffmpeg

  if [[ $# -ne 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input> <output>"
    return 1
  fi

  local source_height
  source_height="$(ffheight "$1")" || return 1
  echo "Video Height: $source_height"

  local target_height
  target_height=$(ffcropheight "$1") || return 1

  local crop_multiple
  crop_multiple=6

  # Get source crop height as a multiple of a
  # number depending on initial resolution
  local target_height_multiple
  target_height_multiple=$(((target_height + crop_multiple - 1) / crop_multiple * crop_multiple)) || return 1

  if [[ $target_height_multiple -lt $source_height ]]; then
    echo "Crop Height: $target_height_multiple"
  else
    echo "No crop required. Skipping"
    exit 0
  fi

  ffmpeg \
    -hide_banner -v warning \
    -nostdin -stats \
    -i "$1" \
    -c:v libx264 \
    -preset ultrafast \
    -qp 0 \
    -vf "crop=iw:$target_height_multiple" \
    -c:a copy \
    -c:s copy \
    -y "$2"
}
