#!/bin/bash

function fftv_watch() {
	if [ $# -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <directory>"
		return 1
	fi

	# Get directories
	local current_dir=$(pwd)
	local root_dir=$(abspath "$1")
	local input_dir="$root_dir/input"
	local complete_dir="$input_dir/complete"
	local error_dir="$input_dir/error"
	local output_dir="$root_dir/output"

	# Create required folders if they do not exist
	mkdir -p "$input_dir" "$complete_dir" "$error_dir" "$output_dir" || return 1

	# Change to root directory
	cd "$root_dir" || return 1

	# Start an infinite loop to continuously watch the directory
	inotifywait -m -q -e close_write -e create -e moved_to --format '%w%f' "$input_dir" |
		while read -r input_path; do

			local input_name="$(file_name "$input_path")"
			local extension="$(file_extension "$input_path")"

			# If file is open, break
			if lsof -Fp "$input_path" &>/dev/null; then
				echo "$input_name is open. Skipping"
				break
			fi

			# If file is not an mp4 or mkv, break
			if [[ "$extension" != "mp4" && "$extension" != "mkv" ]]; then
				echo "$input_name is not an mp4 or mkv. Skipping"
				break
			fi

			local output_name="$(
				echo "$input_name" |
					sd -f i '(amzn|dnsp|hmax|atmos)' '' |
					sd -f i '[ .()-]+' '.' |
					sd -f i '1080p' '720p' |
					sd -f i 'web(.)?dl' 'WEB-DL' |
					sd -f i 'DD(P|\+)?(\.)?(5.1|2.0)' '2CH' |
					sd -f i '[hx](\.)?264' 'x265' |
					sd -f i -- '\.[a-z0-9]+\.([a-z0-9]+)$' '-arranhs.$1'
			)"
			local output_path="$output_dir/$output_name"

			# Transcode file and move it when completed/errored
			echo "Transcoding $input_name to $output_name"
			echo

			fftv "$input_path" "$output_path" &&
				mv "$input_path" "$complete_dir" ||
				mv "$input_path" "$error_dir"

		done

	# Change back to current directory
	cd "$current_dir" || return 1
}
