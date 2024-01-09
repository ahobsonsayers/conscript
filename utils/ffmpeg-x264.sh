#!/usr/bin/env bash

function fffilmpass() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input> <output>"
    return 1
  fi

  echo

  # Get files
  local source_file="$1"
  echo "Source File: $source_file"

  local target_file="$2"
  echo "Target File: $target_file"

  local source_name
  source_name="$(file_label "$source_file")" || return 1

  echo

  # Get source info
  local source_bitrate
  source_bitrate="$(ffbitrate video "$source_file")" || return 1
  echo "Source Video Bitrate: $source_bitrate"

  local source_width
  source_width="$(ffwidth "$source_file")" || return 1
  echo "Source Video Width: $source_width"

  local source_height
  source_height="$(ffheight "$source_file")" || return 1
  echo "Source Video Height: $source_height"

  local source_crop_height
  source_crop_height="$(ffcropheight "$source_file")" || return 1
  echo "Source Video Crop Height: $source_crop_height"

  local source_colour
  source_colour="$(ffcolour "$source_file")" || return 1
  echo "Source Video Colour: $source_colour"

  local source_audio_bitrate
  source_audio_bitrate="$(ffbitrate audio "$source_file")" || return 1
  echo "Source Audio Bitrate: $source_audio_bitrate"

  local source_audio_language
  source_audio_language="$(ffaudiolang "$source_file")" || return 1
  echo "Source Audio Language: $source_audio_language"

  echo

  # Get crop params
  local crop_param
  if [[ $source_crop_height -lt "$((source_height - 2))" ]]; then
    echo "Cropping to a height of $source_crop_height"
    crop_param="crop=iw:${source_crop_height},"
    # libplacebo cropping. Doesnt seem to work atm
    # crop_param="crop_h=$source_crop_height:"
  else
    echo "No cropping required. Skipping"
  fi

  # Get colour param
  local colour_params
  if [[ -z $source_colour || $source_colour == "unknown" ]]; then
    echo "Unknown source colour. Skipping colour mapping"
  elif [[ $source_colour == "bt709" ]]; then
    echo "No colour mapping required. Skipping"
  else
    echo "Mapping colours to BT.709"
    colour_params="
			tonemapping=bt.2390:
			tonemapping_param=0.5:
			colorspace=bt709:
			color_primaries=bt709:
			color_trc=bt709:
			range=limited:
		"
  fi

  # Get target bitrate and scale params
  local scale_params
  if [[ $source_width -eq 3840 || $source_width -eq 2560 ]]; then
    echo "Scaling to 1080p"
    scale_params="w=1920:h=-1:downscaler=ewa_lanczos:"
    # scale_params="zscale=w=1920:h=-1:filter=spline36,"
  elif [[ $source_width -eq 1920 || $source_width -eq 1280 ]]; then
    echo "No scaling required. Skipping"
  else
    error "Unsupported resolution"
    return 1
  fi

  # Get pass params and ffmpeg output args depending on pass
  local pass_num
  local output_args
  if [[ $target_file == "-" ]]; then
    pass_num=1
    output_args="
			-an
			-sn
			-f null
			-
		"
  else
    pass_num=2
    output_args="
			-map 0:a:0
			-c:a libfdk_aac
			-profile:a aac_low
			-vbr 3
			-ac 6 \
			-map 0:s:m:language:eng?
			-c:s copy
			-map_metadata:g -1
			-map_metadata:s -1
			-metadata source=\"$source_name\"
			-metadata:s:a language=\"$source_audio_language\"			
			-metadata:s:s language=eng
			-y \"$target_file\"
		"
  fi

  # Split output args into an array
  local output_args_array
  array_parse output_args_array "$output_args"

  echo
  echo "Transcoding pass $pass_num"
  echo
  nice ffmpeg \
    -hide_banner -v warning \
    -nostdin -stats \
    -init_hw_device vulkan \
    -i "$source_file" \
    -map 0:v:0 \
    -c:v libx264 \
    -profile:v high \
    -b:v 2.5M \
    -preset:v slower \
    -tune film \
    -pass "$pass_num" \
    -vf "
			$crop_param
			hwupload,
			libplacebo=
				$colour_params
				$scale_params
				deband=true:
				format=yuv420p,
			hwdownload,
			format=yuv420p
		" \
    -x264-params "
			bframes=8:
			ref=6:
			aq-mode=3:
			merange=24
    " \
    "${output_args_array[@]}" || return 1

  # If output file exists asd stat tags
  if [[ -f $target_file ]]; then

    echo

    local video_duration
    video_duration="$(ffduration video "$target_file")"
    echo "Transcoded Video Duration: $video_duration"

    local audio_start
    audio_start="$(ffstart audio "$target_file")"
    echo "Transcoded Audio Offset: $audio_start"

    local remux_file="remux-$target_file"

    echo
    echo "Remuxing file to sync media tracks"
    echo
    ffmpeg \
      -hide_banner -v warning \
      -nostdin -stats \
      -i "$target_file" \
      -ss "${audio_start#-}" \
      -to "$video_duration" \
      -i "$target_file" \
      -map 0:v \
      -map 1:a \
      -map 1:s \
      -c copy \
      -copyts \
      -y "$remux_file"

    # Move remux file to destination
    mv "$remux_file" "$target_file"

    echo
    echo "Adding statistic tags using mkvpropedit"
    echo
    mkvpropedit --add-track-statistics-tags "$target_file"
  fi

  echo
}

function fffilm() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <input> <output>"
    return 1
  fi

  fftvpass "$1" - &&
    fftvpass "$1" "$2" ||
    return 1
}
