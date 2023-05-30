# homebrew
HOMBREW_PREFIX="/home/linuxbrew/.linuxbrew"
if [ -d "$HOMBREW_PREFIX" ]; then
    eval "$($HOMBREW_PREFIX/bin/brew shellenv)"
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# add user home bin to path
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# add user local bin to path
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# go
if command -v go &>/dev/null; then
    export PATH="$(go env GOPATH)/bin:$PATH"
fi

# vulkan
BREW_VK_DRIVER_FILES="$HOMBREW_PREFIX/share/vulkan/icd.d"
if [ -d "$BREW_VK_DRIVER_FILES" ]; then
    export VK_DRIVER_FILES="$BREW_VK_DRIVER_FILES"
fi

# functions
for file in $HOME/functions/*; do
    . "$file"
done
