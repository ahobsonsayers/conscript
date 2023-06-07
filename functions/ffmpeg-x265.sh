#!/bin/bash

function fftvpass() {
	if [[ $# -ne 2 ]]; then
		echo "Usage: ${FUNCNAME[0]} <input> <output>"
		return 1
	fi

	# Get source info
	source_name="$(file_label "$1")"
	source_bitrate="$(ffbitrate "$1")"
	source_width="$(ffwidth "$1")"
	source_height="$(ffheight "$1")"
	source_crop_height="$(ffcropheight "$1")"

	# Get target bitrate and scale param
	if [ "$source_width" -eq 1920 ]; then
		# 1080p source
		target_bitrate="$((source_bitrate / 9))"
		scale_param="w=1280:h=-1:downscaler=ewa_lanczos:"
	elif [ "$source_width" -eq 1280 ]; then
		# 720p source
		target_bitrate="$((source_bitrate / 4))"
		scale_param=""
	else
		echo "Unsupported resolution"
		return 1
	fi

	# Get crop params
	if [ "$source_crop_height" -lt "$source_height" ]; then
		crop_param="crop=iw:$source_crop_height,"
	else
		crop_param=""
	fi

	# Get ffmpeg iutout args depending
	# whether first or second pass
	if [ "$2" = "-" ]; then
		echo "First Pass"
		pass=1
		ffmpeg_output_args="
      -an
      -sn
      -f null
      -
    "
	else
		echo "Second Pass"
		pass=2
		ffmpeg_output_args="
      -map 0:a:0
      -c:a libfdk_aac
      -profile:a aac_he_v2
      -vbr 3
      -ac 2
      -af \"asetpts=PTS+0.2/TB\"
      -metadata:s:a title=\"2.0\"
      -map 0:s:m:language:eng?
      -c:s copy
      -map_metadata -1
      -metadata source=\"$source_name\"
      -y
      $2
    "
	fi

	# Split output args into an array
	local ffmpeg_output_args_array
	array_parse ffmpeg_output_args_array "$ffmpeg_output_args"

	ffmpeg \
		-hide_banner -v warning \
		-nostdin -stats \
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
      pass=$pass
    " \
		-vf "
        $crop_param
        hwupload,
        libplacebo=
          $scale_param
          deband=true:
          colorspace=bt709:
          color_primaries=bt709:
          color_trc=bt709:
          range=limited:
          format=yuv420p10le,
        hwdownload,
        format=yuv420p10le
      " \
		"${ffmpeg_output_args_array[@]}"
}

function fftv() {
	if [[ $# -ne 2 ]]; then
		echo "Usage: ${FUNCNAME[0]} <input> <output>"
		return 1
	fi

	fftvpass "$1" - &&
		fftvpass "$1" "$2"
}
