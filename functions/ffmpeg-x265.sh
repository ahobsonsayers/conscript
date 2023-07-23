#!/usr/bin/env bash

function fftvpass() {
	if [[ $# -ne 2 ]]; then
		echo "Usage: ${FUNCNAME[0]} <input> <output>"

		return 1
	fi

	# Get names
	local source_name
	source_name="$(file_label "$1")" || return 1
	echo "Source Name: $source_name"

	local target_name
	target_name="$(file_label "$2")" || return 1
	echo "Target Name: $target_name"

	echo

	# Get source info
	local source_bitrate
	source_bitrate="$(ffbitrate "$1")" || return 1
	echo "Source Bitrate: $source_bitrate"

	local source_width
	source_width="$(ffwidth "$1")" || return 1
	echo "Source Width: $source_width"

	local source_height
	source_height="$(ffheight "$1")" || return 1
	echo "Source Height: $source_height"

	local source_crop_height
	source_crop_height="$(ffcropheight "$1")" || return 1
	echo "Source Crop Height: $source_crop_height"

	local source_colour
	source_colour="$(ffcolour "$1")" || return 1
	echo "Source Colour: $source_colour"

	local source_audio_language
	source_audio_language="$(ffaudiolang "$1")" || return 1
	echo "Source Audio Language: $source_audio_language"

	echo

	# Get target bitrate and scale params
	local target_bitrate
	local scale_params
	if [ "$source_width" -eq 1920 ]; then
		echo "Scaling to 720p"
		scale_params="w=1280:h=-1:downscaler=ewa_lanczos:"
		# scale_params="zscale=w=1280:h=-1:filter=spline36,"
	elif [ "$source_width" -eq 1280 ]; then
		echo "No scaling required. Skipping"
	else
		error "Unsupported resolution"
		return 1
	fi

	# Get crop params
	local crop_param
	if [ "$source_crop_height" -lt "$((source_height - 2))" ]; then
		echo "Cropping to a height of $source_crop_height"
		crop_param="crop=iw:${source_crop_height},"
		# libplacebo cropping. Doesnt seem to work atm
		# crop_param="crop_h=$source_crop_height:"
	else
		echo "No cropping required. Skipping"
	fi

	# Get colour param
	local colour_params
	if [ -z "$source_colour" ] || [ "$source_colour" = "unknown" ]; then
		echo "Unknown source colour. Skipping colour mapping"
	elif [ "$source_colour" = "bt709" ]; then
		echo "No colour mapping required. Skipping"
	else
		echo "Mapping colours to BT.709"
		colour_params="
			colorspace=bt709:
			color_primaries=bt709:
			color_trc=bt709:
			range=limited:
		"
	fi

	echo

	# Get pass params and ffmpeg output args depending on pass
	local pass_params
	local output_args
	local analysis_file="x265_analysis.dat"
	if [ "$2" = "-" ]; then
		echo "First Pass"
		pass_params="
			pass=1:
			analysis-save=$analysis_file:
			analysis-save-reuse-level=10
		"
		output_args="
			-an
			-sn
			-f null
			-
		"
	else
		echo "Second Pass"
		pass_params="
			pass=2:
			analysis-load=$analysis_file:
			analysis-load-reuse-level=10
		"
		output_args="
			-map 0:a:0
			-c:a libfdk_aac
			-profile:a aac_he_v2
			-vbr 5
			-ac 2
            -af "aresample=first_pts=0"
			-map 0:s:m:language:eng?
			-c:s copy
			-map_metadata:g -1
			-map_metadata:s -1
			-metadata source=\"$source_name\"
			-metadata:s:a language=\"$source_audio_language\"			
			-metadata:s:s language=eng
			-y
			$2
		"
	fi

	echo

	# Split output args into an array
	local output_args_array
	array_parse output_args_array "$output_args"

	# Run ffmpeg
	nice ffmpeg \
		-hide_banner -v warning \
		-nostdin -stats \
		-init_hw_device vulkan \
		-i "$1" \
		-map 0:v:0 \
		-c:v libx265 \
		-profile:v main10 \
		-b:v "800k" \
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
			psy-rd=0.5:
			psy-rdoq=0.5:
			$pass_params
		" \
		"${output_args_array[@]}" || return 1

	# If output file exists asd stat tags
	if [[ -f $2 ]]; then
		echo
		echo "Adding statistic tags using mkvpropedit"
		echo
		mkvpropedit --add-track-statistics-tags "$2"
	fi

	echo
}

function fftv() {
	if [[ $# -ne 2 ]]; then
		echo "Usage: ${FUNCNAME[0]} <input> <output>"
		return 1
	fi

	fftvpass "$1" - &&
		fftvpass "$1" "$2" ||
		return 1
}
