#!/bin/bash

function fffilmpass1() {
  if [[ $# -ne 1 ]]; then
    echo 'fffilmpass1 INPUT'
  else
    target_height=$(ffcropheight "$1")
    if [ $(ffishdr "$1") = true ]; then
      tone_map="
        tonemapping=bt.2390:
        tonemapping_param=0.5:
        colorspace=bt709:
        color_primaries=bt709:
        color_trc=bt709:
        range=limited:
      "
    fi
    ffmpeg \
      -init_hw_device vulkan=gpu \
      -filter_hw_device gpu \
      -i "$1" \
      -map 0:v:0 \
      -c:v libx264 \
      -profile:v high \
      -b:v 2.5M \
      -preset:v slower \
      -tune film \
      -x264-params "
        bframes=8:
        ref=6:
        aq-mode=3:
        merange=24
      " \
      -vf "
        crop=iw:${target_height},
        hwupload,
        libplacebo=
          w=1920:h=-1:
          downscaler=ewa_lanczos:
          deband=true:
          ${tone_map}
          format=yuv420p,
        hwdownload,
        format=yuv420p
      " \
      -an \
      -sn \
      -pass 1 \
      -f null \
      -
  fi
}

function fffilmpass2() {
  if [[ $# -ne 2 ]]; then
    echo 'fffilmpass2 INPUT OUTPUT'
  else
    target_height=$(ffcropheight "$1")
    if [ $(ffishdr "$1") = true ]; then
      tone_map="
        tonemapping=bt.2390:
        tonemapping_param=0.5:
        colorspace=bt709:
        color_primaries=bt709:
        color_trc=bt709:
        range=limited:
      "
    fi
    ffmpeg \
      -init_hw_device vulkan=gpu \
      -filter_hw_device gpu \
      -i "$1" \
      -map 0:v:0 \
      -c:v libx264 \
      -profile:v high \
      -b:v 2.5M \
      -preset:v slower \
      -tune film \
      -x264-params "
        bframes=8:
        ref=6:
        aq-mode=3:
        merange=24
      " \
      -vf "
        crop=iw:${target_height},
        hwupload,
        libplacebo=
          w=1920:h=-1:
          downscaler=ewa_lanczos:
          deband=true:
          ${tone_map}
          format=yuv420p,
        hwdownload,
        format=yuv420p
      " \
      -map 0:a:0 \
      -c:a aac \
      -ac 6 \
      -b:a 224K \
      -metadata:s:a title="5.1" \
      -map 0:s:m:language:eng? \
      -c:s copy \
      -map_metadata -1 \
      -pass 2 \
      "$2"
  fi
}

function fffilm() {
  if [[ $# -ne 2 ]]; then
    echo 'ffencode INPUT OUTPUT'
  else
    fffilmpass1 "$1" &&
      fffilmpass2 "$1" "$2"
  fi
}
