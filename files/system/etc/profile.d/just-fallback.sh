# Fallback just to system justfile when no local justfile is present
if [ -n "$PS1" ] || [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
    just() {
        for arg in "$@"; do
            case "$arg" in
                -f|--justfile|-h|--help|-V|--version|--man)
                    command just "$@"
                    return $?
                    ;;
            esac
        done

        local dir="$PWD"
        while [ "$dir" != "/" ] && [ -n "$dir" ]; do
            if [ -f "$dir/justfile" ] || [ -f "$dir/Justfile" ] || [ -f "$dir/.justfile" ]; then
                command just "$@"
                return $?
            fi
            dir="$(dirname "$dir")"
        done
        if [ -f "/justfile" ] || [ -f "/Justfile" ] || [ -f "/.justfile" ]; then
            command just "$@"
            return $?
        fi

        if [ -x /usr/bin/blujust ]; then
            /usr/bin/blujust "$@"
        elif [ -f /usr/share/bluebuild/justfile ]; then
            command just --justfile /usr/share/bluebuild/justfile "$@"
        else
            command just "$@"
        fi
    }
fi
