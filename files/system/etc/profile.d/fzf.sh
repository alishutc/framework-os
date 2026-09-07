# Enable fzf key bindings (Ctrl+T, Ctrl+R, Alt+C) for interactive bash shells
if [ "$PS1" ] && [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
    source /usr/share/fzf/shell/key-bindings.bash
fi
