# homebrew
HOMBREW_PREFIX="/home/linuxbrew/.linuxbrew"
if [[ -d "$HOMBREW_PREFIX" ]]; then
    eval "$($HOMBREW_PREFIX/bin/brew shellenv)"
fi

# homebrew completions
if [[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
  source "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
else
  for completion in "$HOMEBREW_PREFIX/etc/bash_completion.d/"*; do
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
    export PATH="$(go env GOPATH)/bin:$PATH"
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