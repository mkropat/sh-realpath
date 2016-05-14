#!/bin/sh

realpath() {
    canonicalize_path "$(resolve_symlinks "$1")"
}

resolve_symlinks() {
    _resolve_symlinks "$1"
}

_resolve_symlinks() {
    _assert_no_path_cycles "$@" || return

    local dir_context path
    path=$(readlink -- "$1")
    if [ $? -eq 0 ]; then
        dir_context=$(dirname -- "$1")
        _resolve_symlinks "$(_prepend_dir_context_if_necessary "$dir_context" "$path")" "$@"
    else
        printf '%s\n' "$1"
    fi
}

_prepend_dir_context_if_necessary() {
    if [ "$1" = . ]; then
        printf '%s\n' "$2"
    else
        _prepend_path_if_relative "$1" "$2"
    fi
}

_prepend_path_if_relative() {
    case "$2" in
        /* ) printf '%s\n' "$2" ;;
         * ) printf '%s\n' "$1/$2" ;;
    esac
}

_assert_no_path_cycles() {
    local target path

    target=$1
    shift

    for path in "$@"; do
        if [ "$path" = "$target" ]; then
            return 1
        fi
    done
}

canonicalize_path() {
    if [ -d "$1" ]; then
        _canonicalize_dir_path "$1"
    else
        _canonicalize_file_path "$1"
    fi
}

_canonicalize_dir_path() {
    (cd "$1" 2>/dev/null && pwd -P)
}

_canonicalize_file_path() {
    local dir file
    dir=$(dirname -- "$1")
    file=$(basename -- "$1")
    (cd "$dir" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$file")
}

canonicalize_missing() {
    local path dir

    path=$1

    if [ $(printf "%s" $path | cut -c 1) != "/" ]; then
        path=$(printf "%s/%s" $(pwd) $path)
    fi

    path=$(printf "%s" $path | sed -e 's%^\./%%g' -e 's%/\./%/%g' -e ':begin' -e 's%\([^/]*\)/\.\./%%' -e 'tbegin')

    {
        old_IFS=$IFS
        IFS=/
        set $path
        IFS=$old_IFS

        dir='/'
        for i in $@; do
            if [ "X$i" = "X" ]; then
                continue
            fi

            cd $dir
            dir=$(printf "%s/%s" $dir $(resolve_symlinks $i))
        done
    }

    printf "%s\n" $dir | sed -e 's%//%/%g' -e 's%^\./%%g' -e 's%/\./%/%g' -e ':begin' -e 's%\([^/]*\)/\.\./%%' -e 'tbegin'
}

# Optionally, you may also want to include:

### readlink emulation ###

readlink() {
    if _has_command readlink; then
        _system_readlink "$@"
    else
        _emulated_readlink "$@"
    fi
}

_has_command() {
    hash -- "$1" 2>/dev/null
}

_system_readlink() {
    command readlink "$@"
}

_emulated_readlink() {
    if [ "$1" = -- ]; then
        shift
    fi

    _gnu_stat_readlink "$@" || _bsd_stat_readlink "$@"
}

_gnu_stat_readlink() {
    local output
    output=$(stat -c %N -- "$1" 2>/dev/null) &&

    printf '%s\n' "$output" |
        sed "s/^‘[^’]*’ -> ‘\(.*\)’/\1/
             s/^'[^']*' -> '\(.*\)'/\1/"
    # FIXME: handle newlines
}

_bsd_stat_readlink() {
    stat -f %Y -- "$1" 2>/dev/null
}
