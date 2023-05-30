#!/bin/bash

function fftv_watch() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <directory>"
    return 1
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
    while read -r input_path; do

      input_name="$(file_name "$input_path")"
      input_label="$(file_label "$input_path")"
      extension="$(extension "$input_path")"

      # If file is and mkv
      if [[ "$extension" == "mkv" || "$extension" == "mp4" ]]; then

        output_label="$(
          echo "$input_label" |
            sd -f i '(amzn|dnsp|hmax|atmos)' '' |
            sd -f i '[ .()-]+' '.' |
            sd -f i '1080p' '720p' |
            sd -f i 'web(.)?dl' 'WEB-DL' |
            sd -f i 'DD(P|\+)?(\.)?(5.1|2.0)' '2CH' |
            sd -f i '[hx](\.)?264' 'x265' |
            sd -f i -- '\.[a-zA-Z0-9]+$' '-arranhs'
        )"
        output_name="${output_label}.${extension}"
        output_path="${output_dir}/${output_name}"

        # Transcode file and move it when completed/errored
        echo "Transcoding ${input_name} to ${output_name}"

        fftv "$input_path" "$output_path" &&
          mv "$input_path" "$complete_dir" ||
          mv "$input_path" "$error_dir"

      fi
    done
}
