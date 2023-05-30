#!/bin/bash

function fftvpass1() {
  if [[ $# -ne 1 ]]; then
    echo 'fftvpass1 INPUT'
  else
    source_bitrate=$(ffbitrate "$1")
    target_bitrate=$(((source_bitrate / 250) * 25))
    target_height=$(ffcropheight "$1")
    ffmpeg \
      -loglevel warning \
      -hide_banner \
      -stats \
      -init_hw_device vulkan \
      -i "$1" \
      -map 0:v:0 \
      -c:v libx265 \
      -profile:v main10 \
      -b:v "${target_bitrate}k" \
      -preset:v slow \
      -x265-params "
        bframes=10:
        ref=6:
        subme=7:
        max-merge=5:
        amp=1:
        weightb=1:
        psy-rd=1:
        pass=1
      " \
      -vf "
        crop=iw:${target_height},
        hwupload,
        libplacebo=
          w=1280:h=-1:
          downscaler=ewa_lanczos:
          deband=true:
          colorspace=bt709:
          color_primaries=bt709:
          color_trc=bt709:
          range=limited:
          format=yuv420p10le,
        hwdownload,
        format=yuv420p10le
      " \
      -an \
      -sn \
      -f null \
      -
  fi
}

function fftvpass2() {
  if [[ $# -ne 2 ]]; then
    echo 'fftvpass2 INPUT OUTPUT'
  else
    source_bitrate=$(ffbitrate "$1")
    target_bitrate=$(((source_bitrate / 250) * 25))
    target_height=$(ffcropheight "$1")
    ffmpeg \
      -loglevel warning \
      -hide_banner \
      -stats \
      -init_hw_device vulkan \
      -i "$1" \
      -map 0:v:0 \
      -c:v libx265 \
      -profile:v main10 \
      -b:v "${target_bitrate}k" \
      -preset:v slow \
      -x265-params "
        bframes=10:
        ref=6:
        subme=7:
        max-merge=5:
        amp=1:
        weightb=1:
        psy-rd=1:
        pass=2
      " \
      -vf "
        crop=iw:${target_height},
        hwupload,
        libplacebo=
          w=1280:h=-1:
          downscaler=ewa_lanczos:
          deband=true:
          colorspace=bt709:
          color_primaries=bt709:
          color_trc=bt709:
          range=limited:
          format=yuv420p10le,
        hwdownload,
        format=yuv420p10le
      " \
      -map 0:a:0 \
      -c:a libfdk_aac \
      -profile:a aac_he_v2 \
      -vbr 3 \
      -ac 2 \
      -af "asetpts=PTS+0.2/TB" \
      -metadata:s:a title="2.0" \
      -map 0:s:m:language:eng? \
      -c:s copy \
      -map_metadata -1 \
      -y \
      "$2"
  fi
}

function fftv() {
  if [[ $# -ne 2 ]]; then
    echo 'fftv INPUT OUTPUT'
  else
    fftvpass1 "$1" &&
      fftvpass2 "$1" "$2"
  fi
}
