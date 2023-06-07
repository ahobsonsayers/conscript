#!/bin/bash

# homebrew
HOMBREW_PREFIX="/home/linuxbrew/.linuxbrew"
if [[ -d "$HOMBREW_PREFIX" ]]; then
    eval "$($HOMBREW_PREFIX/bin/brew shellenv)"
fi

# homebrew completions
homebrew_completion="$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
homebrew_completions="$HOMEBREW_PREFIX/etc/bash_completion.d/"*
if [[ -r "$homebrew_completion" ]]; then
    source "$homebrew_completion"
else
    for completion in "$homebrew_completions"*; do
        source "$completion"
    done
fi

# homebrew vulkan
brew_vulkan="$HOMBREW_PREFIX/share/vulkan/icd.d"
if [[ -d "$brew_vulkan" ]]; then
    export VK_DRIVER_FILES="$brew_vulkan"
fi

# add user bin to path
user_bin="$HOME/bin"
if [[ -d "$user_bin" ]]; then
    PATH="$user_bin:$PATH"
fi

# add user local bin to path
user_local_bin="$HOME/.local/bin"
if [[ -d "$user_local_bin" ]]; then
    PATH="$user_local_bin:$PATH"
fi

# go
if command -v go &>/dev/null; then
    PATH="$(go env GOPATH)/bin:$PATH"
fi

# source functions
for function_file in "$HOME/functions/"*; do
    source "$function_file"
done

# source .bashrc
bashrc_path="$HOME/.bashrc"
if [ -f "$bashrc_path" ]; then
    source "$bashrc_path"
fi
