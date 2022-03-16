#! /usr/bin/env bash
# =========================================================================
# recursextract.sh                             Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:    ./recursextract.sh <ante args> -- <path> ...
# Semantics: checks if <path> =~ tar.gz; if applicable extracts it and
#            recurses; otherwise executes <ante args> <path>; repeats with
#            the next path.
# Use case   find <source_dir> -type f -print0 | xargs -0\
#            ./recursextract.sh ./indexyfile.sh <target_directory> --
# =========================================================================

this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$this")
source "$this_dir"/error_exit

help()
{
    echo "Syntax: ./recursextract.sh <ante args> -- <path> ..."
    echo "Options:"
    echo "  --help"   
    echo "Also see: the source file"
}

ante_args=()
while (( $# > 0 ))
do
    case ${1} in
        ( '--help' ) help; exit;;
        ( '--' ) shift; break ;;
        ( * ) ante_args+=("$1"); shift;;
    esac
done

if
    (( $# == 0 ))
then
    exit 0
fi

path="$1"
shift

if
    [[ $path =~ .tar.gz$ ]]
then

    # <div>
    # https://stackoverflow.com/a/53063602/9243116
    dir_tmp=$(mktemp -d)

    [[ -d "$dir_tmp" ]] || error_exit "$this" "$dir_tmp"

    trap "exit 1"           HUP INT PIPE QUIT TERM
    trap 'rm -rf "$dir_tmp"' EXIT
    # </div>

    tar -xvzf "$path" --directory="$dir_tmp" 1>/dev/null

    find "$dir_tmp" -type f -print0 | xargs -0 "$this" "${ante_args[@]}" --

else
    "${ante_args[@]}" "$path"
fi

(( $# == 0 )) || "$this" "${ante_args[@]}" -- "$@"
