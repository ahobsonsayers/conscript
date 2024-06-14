#!/usr/bin/env bash

# Screenshot
function ffscreenshot() {
  check_cmds ffmpeg

  if [[ $# -ne 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input> <timestamp>"
    echo "<timestamp> format: H[H]:M[M]:S[S]"
    return 1
  fi

  local directory
  local file_label

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
  check_cmds ffmpeg

  if [[ $# -ne 3 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input> <timestamp> <duration>"
    echo "<timestamp> and <duration> format: H[H]:M[M]:S[S]"
    return 1
  fi

  local directory
  local file_label
  local file_extension

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

# Get video width
function ffwidth() {
  check_cmds ffmpeg

  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  ffprobe \
    -hide_banner -v warning \
    -of "default=noprint_wrappers=1:nokey=1" \
    -select_streams v:0 \
    -show_entries "stream=width" \
    "$1"
}

# Get video height
function ffheight() {
  check_cmds ffmpeg

  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  ffprobe \
    -hide_banner -v warning \
    -of "default=noprint_wrappers=1:nokey=1" \
    -select_streams v:0 \
    -show_entries "stream=height" \
    "$1"
}

# Get Crop Height
function ffcropheight() {
  check_cmds ffmpeg

  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  local duration
  local step

  duration=$(media_duration_seconds video "$1")
  floored_duration=$(calc "floor($duration)")
  step=$((floored_duration / 11))

  for i in $(seq 1 10); do
    ffmpeg \
      -hide_banner \
      -nostdin -stats \
      -ss "$((i * step))" \
      -i "$1" \
      -t 1 \
      -vf "cropdetect=round=2" \
      -f null \
      - 2>&1 |
      grep -o "crop=.*" |
      cut -d : -f 2
  done |
    sort -bh | uniq -c | sort -bh |
    tail -1 | awk '{print $2}'
}

# Get bitrate
function ffbitrate() {
  if [[ $# != 2 || ! $1 =~ ^("general"|"video"|"audio")$ ]]; then
    echo "Usage: ${FUNCNAME[0]} [type] <input>"
    echo "[type] must be one of: general, video, audio"
    return 1
  fi

  local type="$1"
  local file="$2"

  local bitrate
  bitrate="$(
    mediainfo \
      --Output="${type^};%BitRate%" \
      "$file"
  )"

  echo $((bitrate / 1000))
}

# Get video colour information
function ffcolourinfo() {
  check_cmds ffprobe

  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  ffprobe \
    -hide_banner -v warning \
    -select_streams v:0 \
    -show_streams \
    -of json \
    "$1" |
    jq '.streams[0] | {
          color_primaries: .color_primaries, 
          color_space: .color_space, 
          color_transfer: .color_transfer, 
        }'
}

# Get video colour
# This only works if all parts of colour
# info are consistent
function ffcolour() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  local colour_info
  local color_primaries
  local color_space
  local color_transfer

  colour_info=$(ffcolourinfo "$1")
  color_primaries=$(jq -r '.color_primaries' <<<"$colour_info")
  color_space=$(jq -r '.color_space' <<<"$colour_info")
  color_transfer=$(jq -r '.color_transfer' <<<"$colour_info")

  if [[ $color_primaries == "null" ]] &&
    [[ $color_space == "null" ]] &&
    [[ $color_transfer == "null" ]]; then
    echo unknown
  elif [[ $color_primaries == "bt709" || $color_primaries == "null" ]] &&
    [[ $color_space == "bt709" || $color_space == "null" ]] &&
    [[ $color_transfer == "bt709" || $color_transfer == "null" ]]; then
    echo bt709
  elif [[ $color_primaries == "bt2020" || $color_primaries == "null" ]] &&
    [[ $color_space == "bt2020nc" || $color_space == "null" ]] &&
    [[ $color_transfer == "smpte2084" || $color_transfer == "null" ]]; then
    echo bt2020
  else
    error "Unsupported Colour"
    error "$colour_info"
    return 1
  fi
}

# Count BFrames
function ffbframes() {
  check_cmds ffprobe

  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  ffprobe \
    -hide_banner -v warning \
    -show_frames \
    "${1}" |
    grep -c "pict_type=B"
}

function ffstart() {
  check_cmds ffprobe

  if ! {
    [[ $# == 1 ]] ||
      [[ $# == 2 && $1 =~ ^("video"|"audio")$ ]]
  }; then
    echo "Usage: ${FUNCNAME[0]} [type] <input>"
    echo "[type] must be one of: video, audio"
    return 1
  fi

  local type="$1"
  local file="$2"

  if [[ $# -eq 1 ]]; then
    type="video"
    file="$1"
  fi

  ffprobe \
    -hide_banner -v warning \
    -of "default=noprint_wrappers=1:nokey=1" \
    -select_streams "${type:0:1}:0" \
    -show_entries "stream=start_time" \
    "$file"
}

# get video encode settings
function ffsettings() {
  check_cmds mediainfo

  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  mediainfo \
    --Output="Video;%Encoded_Library_Settings%" \
    "$1" |
    sed "s| / |\n|g" |
    sort
}

# get video audio language
function ffaudiolang() {
  check_cmds ffprobe

  if [[ $# -ne 1 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input>"
    return 1
  fi

  ffprobe \
    -hide_banner -v warning \
    -of "default=noprint_wrappers=1:nokey=1" \
    -select_streams a:0 \
    -show_entries "stream_tags=language" \
    "$1"
}
