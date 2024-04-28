#!/usr/bin/env bash

function github_release_url {
  if [[ $# -ne 2 ]]; then
    echo "Usage: ${FUNCNAME[0]} <username> <repo>"
    return 1
  fi

  curl -s https://api.github.com/repos/"$1"/"$2"/releases/latest |
    grep -o '"browser_download_url": ".*"' |
    cut -d " " -f 2 |
    tr -d '"'
}
