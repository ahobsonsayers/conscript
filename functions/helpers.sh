function file_name() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <path>"
    exit 1
  fi

  echo "$(basename -- "$1")"
}

function file_label() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <path>"
    exit 1
  fi

  file_name="$(file_name "$@")"
  echo "${file_name%.*}"
}

function file_extension() {
  if [ $# -ne 1 ]; then
    echo "Usage: ${FUNCNAME[0]} <path>"
    exit 1
  fi

  file_name="$(file_name "$@")"
  echo "${file_name##*.}"
}
