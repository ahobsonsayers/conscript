#!/usr/bin/env bash

_rcmount() {
    # Get current word
    local current_word="$2"

    # Get available choices
    local choices
    choices=$(rclone listremotes | grep -v "Local:")

    # Filter choices based on the current word and generate the completion reply.
    mapfile -t COMPREPLY < <(compgen -W "$choices" -- "$current_word")

    return 0
}

# Register the completion function for command(s).
complete -F _rcmount rcmount
complete -F _rcmount rcunmount
