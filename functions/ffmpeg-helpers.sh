#! /bin/bash

# Quality Metrics
# https://github.com/slhck/ffmpeg-quality-metrics
# pipx install ffmpeg-quality-metrics
function ffquality {
  if [[ $# -eq 0 ]] || [[ $# -eq 1 ]]; then
    echo 'ffquality ORGINAL TRANSCODE'
  else
    directory=$(dirname "$2")
    filename=$(basename -- "$2")
    ffmpeg-quality-metrics "$2" "$1" \
      -s lanczos \
      -m vmaf ssim psnr \
      | jq '.global | {
        vmaf: .vmaf.vmaf, 
        ssim: .ssim.ssim_avg, 
        psnr: .psnr.psnr_avg, 
        mse: .psnr.mse_avg 
      }' \
      > "${directory}/${filename%.*}.json"
  fi
}

# Screenshot
function ffscreenshot() {
  if [[ $# -eq 0 ]] || [[ $# -eq 1 ]]; then
    echo 'ffcut INPUT TIMESTAMP'
    echo 'TIMESTAMP format: H[H]:M[M]:S[S]'
  else
    directory=$(dirname "$1")
    filename=$(basename -- "$1")
    ffmpeg -v error \
      -ss "$2" \
      -i "$1" \
      -frames:v 1 \
      -update 1 \
      "${directory}/${filename%.*}.png"
  fi
}

# Cut
function ffcut() {
  if [[ $# -eq 0 ]] || [[ $# -eq 1 ]] || [[ $# -eq 2 ]]; then
    echo 'ffcut INPUT TIMESTAMP DURATION'
    echo 'TIMESTAMP and DURATION format: H[H]:M[M]:S[S]'
  else
    DIR=$(dirname "$1")
    NAME=$(basename -- "$1")
    LABEL="${NAME%.*}"
    EXT="${NAME##*.}"
    ffmpeg -v warning \
	  -i "$1" \
      -ss "$2" \
      -t "$3" \
      -c:v copy \
      -c:a copy \
      "${DIR}/${LABEL}-cut.${EXT}"
  fi
} 

# Count BFrames
function ffbframes() {
  if [[ $# -ne 1 ]]; then
    echo 'ffbframes INPUT'
  else
    ffprobe -v warning \
      -show_frames \
      "${1}" |
      grep pict_type=B |
      wc -l
  fi
}

# Is HDR
function ffishdr() {
  if [[ $# -ne 1 ]]; then
    echo 'ffishdr INPUT'
  else
    STREAMINFO=$(
      ffprobe -v error \
        -show_streams \
        -select_streams v:0 \
        -of json \
        -i "${1}" |
        jq '.streams[0]'
    )
    COLORSPACE=$(jq -r '.color_space' <<<"${STREAMINFO}")
    COLORPRIMARIES=$(jq -r '.color_primaries' <<<"${STREAMINFO}")
    COLORTRANSFER=$(jq -r '.color_transfer' <<<"${STREAMINFO}")
    if [ "${COLORSPACE}" = "bt2020nc" ] ||
      [ "${COLORPRIMARIES}" = "bt2020" ] ||
      [ "${COLORTRANSFER}" = "smpte2084" ]; then
      echo true
    else
      echo false
    fi
  fi
}

# Get Crop Height
function ffcropheight() {
  if [[ $# -ne 1 ]]; then
    echo 'ffcropheight INPUT'
  else
    DURATION=$(ffduration "$1")
    STEP=$((DURATION / 10))
    for i in $(seq 0 10); do
      time=$((i * STEP))
      ffmpeg \
        -ss $time \
        -i "$1" \
        -frames:v 1 \
        -vf "cropdetect=round=2" \
        -f null \
        - 2>&1 |
        grep -o crop=.* |
        cut -d : -f 2
    done |
      uniq -c | sort -bh |
      tail -1 | awk '{print $2}'
  fi
}

# Print Encode Settings
function ffsettings() {
  if [[ $# -ne 1 ]]; then
    echo 'ffsettings INPUT'
  else
    mediainfo --Output=JSON "$1" |
      jq -r '.media.track[1].Encoded_Library_Settings' |
      sed "s| / |\n|g" |
      sort
  fi
}

# Print Duration
function ffduration() {
  if [[ $# -ne 1 ]]; then
    echo 'ffduration INPUT'
  else
    ffprobe \
      -v error \
      -show_entries "format=duration" \
      -of "default=noprint_wrappers=1:nokey=1" \
      "$1" |
    cut -d . -f 1
  fi
}

# Print Bitrate
function ffbitrate() {
  if [[ $# -ne 1 ]]; then
    echo 'ffbitrate INPUT'
  else
    BITRATE=$(
      ffprobe \
        -v error \
        -show_entries "format=bit_rate" \
        -of "default=noprint_wrappers=1:nokey=1" \
        "$1"
      )
    echo $(( BITRATE / 1000 ))
  fi
}