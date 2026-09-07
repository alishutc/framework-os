# Initialize Starship prompt for interactive bash shells
if [ "$PS1" ] && command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi
