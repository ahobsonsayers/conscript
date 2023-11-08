#!/usr/bin/env bash

function fftv() {
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

  local source_label
  source_label="$(file_label "$source_file")" || return 1

  local target_dir
  local target_label
  local target_extension
  target_dir="$(dirname "$target_file")" || return 1
  target_label="$(file_label "$target_file")" || return 1
  target_extension="$(file_extension "$target_file")" || return 1

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

  # Get scale params
  local scale_params
  local crop_multiple # Could use 4 * source_width / 1280 ?
  if [[ $source_width -eq 1920 ]]; then
    echo "Scaling source to 720p"
    scale_params="w=1280:h=-1:downscaler=ewa_lanczos:"
    crop_multiple=6
    # scale_params="zscale=w=1280:h=-1:filter=spline36,"
  elif [[ $source_width -eq 1280 ]]; then
    scale_params=""
    crop_multiple=2 # Could be 4?
    echo "No source scaling required. Skipping"
  else
    error "Unsupported resolution"
    return 1
  fi

  # Get source crop height as a multiple of a particular number
  # depending on initial resolution
  local source_crop_height_multiple
  source_crop_height_multiple=$(((source_crop_height + crop_multiple - 1) / crop_multiple * crop_multiple)) || return 1

  # Get crop paramslocal crop_param
  if [[ $source_crop_height_multiple -lt $source_height ]]; then
    echo "Cropping source to a height of $source_crop_height_multiple"
    crop_param="crop=iw:$source_crop_height_multiple,"
    # libplacebo cropping. Doesnt seem to work atm
    # crop_param="crop_h=$source_crop_height_multiple:"
  else
    echo "No source cropping required. Skipping"
  fi

  # Get colour param
  local colour_params
  if [[ -z $source_colour ]] || [[ $source_colour == "unknown" ]]; then
    echo "Unknown source colour. Skipping colour mapping"
  elif [[ $source_colour == "bt709" ]]; then
    echo "No source colour mapping required. Skipping"
  else
    echo "Mapping source colours to BT.709"
    colour_params="
			tonemapping=bt.2390:
			tonemapping_param=0.5:
			colorspace=bt709:
			color_primaries=bt709:
			color_trc=bt709:
			range=limited:
		"
  fi

  if [[ $target_extension != "mkv" ]]; then
    error "Target must be an mkv"
    return 1
  fi

  echo
  echo "Transcoding"
  echo
  nice ffmpeg \
    -hide_banner -v warning \
    -nostdin -stats \
    -init_hw_device vulkan \
    -i "$source_file" \
    -map 0:v:0 \
    -c:v libx265 \
    -profile:v main10 \
    -crf:v 23 \
    -preset:v slower \
    -vf "
			$crop_param
			hwupload,
			libplacebo=
				$colour_params
				$scale_params
				deband=true:
				format=yuv420p10,
			hwdownload,
			format=yuv420p10
		" \
    -x265-params "
			bframes=10:
			ref=6:
			subme=7:
			max-merge=5:
			rd=4:
			limit-refs=3:
			aq-mode=3:
			psy-rd=1:
			psy-rdoq=1
		" \
    -map 0:a:0 \
    -c:a libfdk_aac \
    -profile:a aac_he_v2 \
    -vbr 5 \
    -ac 2 \
    -map 0:s:m:language:eng? \
    -c:s copy \
    -map_metadata:g -1 \
    -map_metadata:s -1 \
    -metadata source="$source_label" \
    -metadata:s:a language="$source_audio_language" \
    -metadata:s:s language=eng \
    -y "$target_file" || return 1

  echo

  # If output file exists, do extra steps
  if [[ -f $target_file ]]; then

    echo "Syncing audio track"

    # Create temp file for syncing
    local sync_file="$target_dir/sync-$target_label.$target_extension"
    cp "$target_file" "$sync_file"

    # Remove codec delay property
    mkvpropedit \
      -e track:a1 \
      -d codec-delay \
      "$sync_file" \
      1>/dev/null

    # Sync and trim audio track
    # overwriting original file
    # Statistic metadata os also written
    mkvmerge \
      --sync 1:-148 \
      --stop-after-video-ends \
      -o "$target_file" \
      "$sync_file" \
      1>/dev/null

    # Remove sync file
    rm "$sync_file"

    echo "Completed syncing audio track"
    echo

  fi

  echo "Finished transcoding"
  echo
}
