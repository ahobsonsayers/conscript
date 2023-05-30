#!/bin/bash

function fftv_watch() {

  # Check arguments
  if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
  fi

  # Get directories
  root_dir="$1"
  input_dir="${root_dir}/input"
  complete_dir="${input_dir}/complete"
  error_dir="${input_dir}/error"
  output_dir="${root_dir}/output"

  # Create folder of they do not exist
  mkdir -p "$input_dir" "$complete_dir" "$error_dir" "$output_dir"

  # Start an infinite loop to continuously watch the directory
  inotifywait -m -q -e create -e moved_to --format '%w%f' "$input_dir" |
    while read -r file_path; do

      # Get file name
      file_name="$(basename "$file_path")"

      # If file is and mkv
      if [[ "$file_name" == *.mkv || "$file_name" == *.mp4 ]]; then

        # Transcode file and move it when completed/errored
        echo "Transcoding: ${file_name}"

        fftv "$file_path" "${output_dir}/${file_name}" &&
          mv "$file_path" "$complete_dir" ||
          mv "$file_path" "$error_dir"

      fi
    done
}
