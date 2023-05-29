#!/bin/bash

# Check if the argument has been provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

root_dir="$1"
input_dir="${root_dir}/input"
complete_dir="${input_dir}/complete"
output_dir="${root_dir}/output"

# Create folder of they do not exist
mkdir -p "$input_dir" "$complete_dir" "$output_dir"

# Start an infinite loop to continuously watch the directory
inotifywait -m -q -e create -e moved_to --format '%w%f' "$input_dir" |
  while read -r file_path; do

    file_name="$(basename "$file_path")"

    # If file is and mkv
    if [[ "$file_name" == *.mkv || "$file_name" == *.mp4 ]]; then

      echo "Transcoding: ${file_name}"

      fftv "$file_path" "${output_dir}/${file_name}"

      mv "$file_path" "$complete_dir"

    fi
  done
