# Fallback just to system justfile when no local justfile is present
function just --wraps just --description "Run just or fallback to system justfile"
    for arg in $argv
        switch $arg
            case -f --justfile -h --help -V --version --man
                command just $argv
                return $status
        end
    end

    set -l dir $PWD
    while test "$dir" != "/" -a -n "$dir"
        if test -f "$dir/justfile" -o -f "$dir/Justfile" -o -f "$dir/.justfile"
            command just $argv
            return $status
        end
        set dir (path dirname $dir)
    end
    if test -f "/justfile" -o -f "/Justfile" -o -f "/.justfile"
        command just $argv
        return $status
    end

    if test -x /usr/bin/blujust
        /usr/bin/blujust $argv
    else if test -f /usr/share/bluebuild/justfile
        command just --justfile /usr/share/bluebuild/justfile $argv
    else
        command just $argv
    end
end
