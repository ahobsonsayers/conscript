#!/bin/bash

# Check if the argument has been provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

root_dir="$1"
input_dir="$root_dir/input"
complete_dir="$input_dir/complete"
output_dir="$root_dir/output"

# Create folder of they do not exist
mkdir -p "$input_dir" "$complete_dir" "$output_dir"

# Start an infinite loop to continuously watch the directory
# while true; do
  inotifywait -m -q -e create -e moved_to --format '%w%f' "$input_dir" |
  while read -r file; do
    # If file is and mkv
    if [[ "$file" == *.mkv || "$file" == *.mp4 ]]; then
      # Print the file name
      echo "Transcoding: $(basename "$file")"
      
      
      
      # Move the file to the "complete" directory
      mv "$file" "$complete_dir"
    fi
  done
# done