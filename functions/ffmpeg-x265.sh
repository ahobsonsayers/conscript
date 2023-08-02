#!/usr/bin/env bash

function fftvpass() {
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

	# Get pass params and ffmpeg output args depending on pass
	local pass_num
	local pass_params
	local output_args
	local analysis_file="x265_analysis.dat"
	if [ "$target_file" = "-" ]; then
		pass_num=1
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
		pass_num=2
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
		-c:v libx265 \
		-profile:v main10 \
		-b:v 800K \
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

	# If output file exists, do extra steps
	if [[ -f "$target_file" ]]; then

		echo
		echo "Syncing audio track"
		echo

		# Create temp file for modification
		local temp_file="temp-$target_file"
		cp "$target_file" "$temp_file"

		# Remove codec delay property
		mkvpropedit \
			-e track:a1 \
			-d codec-delay \
			"$temp_file" \
			1>/dev/null

		echo

		# Sync and trim audio track
		# overwriting original file
		mkvmerge \
			--sync 1:-148 \
			--stop-after-video-ends \
			-o "$target_file" \
			"$temp_file" \
			1>/dev/null

		# Remove temp file
		rm "$temp_file"

		echo "Completed syncing audio track"

	fi

	echo
	echo "Finished transcoding pass $pass_num"
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
