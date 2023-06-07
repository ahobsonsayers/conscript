#!/bin/bash

# Quality Metrics
# https://github.com/slhck/ffmpeg-quality-metrics
# pipx install ffmpeg-quality-metrics
function ffquality {
  if [[ $# -eq 0 ]] || [[ $# -eq 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <original> <timestamp>"
    return 1
  fi

  directory=$(dirname "$2")
  file_label=$(file_label "$2")

  ffmpeg-quality-metrics "$2" "$1" \
    -s lanczos \
    -m vmaf ssim psnr |
    jq '.global | {
        vmaf: .vmaf.vmaf, 
        ssim: .ssim.ssim_avg, 
        psnr: .psnr.psnr_avg, 
        mse: .psnr.mse_avg 
      }' \
      >"${directory}/${file_label%.*}.json"
}

# Screenshot
function ffscreenshot() {
  if [[ $# -eq 0 ]] || [[ $# -eq 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input> <timestamp>"
    echo "<timestamp> format: H[H]:M[M]:S[S]"
    return 1
  fi

  directory=$(dirname "$1")
  file_label=$(file_label "$1")

  ffmpeg \
    -hide_banner -v warning \
    -nostdin \
    -ss "$2" \
    -i "$1" \
    -frames:v 1 \
    -update 1 \
    "${directory}/${file_label}.png"
}

# Cut
function ffcut() {
  if [[ $# -eq 0 ]] || [[ $# -eq 1 ]] || [[ $# -eq 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input> <timestamp> <duration>"
    echo "<timestamp> and <duration> format: H[H]:M[M]:S[S]"
    return 1
  fi

  directory=$(dirname "$1")
  file_label="$(file_label "$1")"
  file_extension="$(file_extension "$1")"

  ffmpeg \
    -hide_banner -v warning \
    -nostdin -stats \
    -i "$1" \
    -ss "$2" \
    -t "$3" \
    -c:v copy \
    -c:a copy \
    "${directory}/${file_label}-cut.${file_extension}"
}

# Count BFrames
function ffbframes() {
  if [[ $# -ne 1 ]]; then
    echo 'Usage: ffbframes <input>'
    return 1
  fi

  ffprobe \
    -hide_banner -v warning \
    -show_frames \
    "${1}" |
    grep -c "pict_type=B"
}

# Is HDR
function ffishdr() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  streaminfo=$(
    ffprobe \
      -hide_banner -v warning \
      -show_streams \
      -select_streams v:0 \
      -of json \
      -i "${1}" |
      jq '.streams[0]'
  )
  colorspace=$(jq -r '.color_space' <<<"$streaminfo")
  colorprimaries=$(jq -r '.color_primaries' <<<"$streaminfo")
  colortransfer=$(jq -r '.color_transfer' <<<"$streaminfo")

  if [ "$colorspace" = "bt2020nc" ] ||
    [ "$colorprimaries" = "bt2020" ] ||
    [ "$colortransfer" = "smpte2084" ]; then
    echo true
  else
    echo false
  fi
}

# Get video width
function ffwidth() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  ffprobe \
    -hide_banner -v warning \
    -select_streams v:0 \
    -show_entries "stream=width" \
    -of "default=noprint_wrappers=1:nokey=1" \
    "$1"
}

# Get video height
function ffheight() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  ffprobe \
    -hide_banner -v warning \
    -select_streams v:0 \
    -show_entries "stream=height" \
    -of "default=noprint_wrappers=1:nokey=1" \
    "$1"
}

# Get Crop Height
function ffcropheight() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  duration=$(ffduration "$1")
  step=$((duration / 10))

  for i in $(seq 0 10); do

    time=$((i * step))

    ffmpeg \
      -hide_banner \
      -nostdin -stats \
      -ss $time \
      -i "$1" \
      -frames:v 1 \
      -vf "cropdetect=round=2" \
      -f null \
      - 2>&1 |
      grep -o "crop=.*" |
      cut -d : -f 2

  done |
    uniq -c | sort -bh |
    tail -1 | awk '{print $2}'
}

# Print Encode Settings
function ffsettings() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  mediainfo --Output=JSON "$1" |
    jq -r '.media.track[1].Encoded_Library_Settings' |
    sed "s| / |\n|g" |
    sort
}

# Print Duration
function ffduration() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  ffprobe \
    -hide_banner -v warning \
    -show_entries "format=duration" \
    -of "default=noprint_wrappers=1:nokey=1" \
    "$1" |
    cut -d . -f 1
}

# Print Bitrate
function ffbitrate() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  bitrate=$(
    ffprobe \
      -hide_banner -v warning \
      -show_entries "format=bit_rate" \
      -of "default=noprint_wrappers=1:nokey=1" \
      "$1"
  )

  echo $((bitrate / 1000))
}
