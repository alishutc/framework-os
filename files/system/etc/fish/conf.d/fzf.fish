# Enable fzf key bindings for interactive fish shells
if status is-interactive; and test -f /usr/share/fzf/shell/key-bindings.fish
    source /usr/share/fzf/shell/key-bindings.fish
    fzf_key_bindings
end
