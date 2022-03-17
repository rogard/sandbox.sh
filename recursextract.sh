#! /usr/bin/env bash
# =========================================================================
# recursextract.sh                             Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:     ./recursextract.sh <commands> -- <path> ...
# Semantics: checks if <path> =~ tar.gz; if so, extracts it and recurses;
#            else executes <commands> <path>; repeats with the next path.
# Requires:  'error_exit' in the same directory
# Use case:  find <source dir> -type f -print0 | xargs -0\
#            ./recursextract.sh ./file_uid.sh <target dir> --
# TODO:      - other compression protocols?
# =========================================================================

this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$this")
source "$this_dir"/error_exit

help()
{
    echo "Syntax: ./recursextract.sh <commands> -- <path> ..."
    echo "Options:"
    echo "  --help"   
    echo "Also see: the source file"
}

cmd_ar=()
while (( $# > 0 ))
do
    case ${1} in
        ( '--help' ) help; exit;;
        ( '--' ) shift; break ;;
        ( * ) cmd_ar+=("$1"); shift;;
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

    find "$dir_tmp" -type f -print0 | xargs -0 "$this" "${cmd_ar[@]}" --

else
    "${cmd_ar[@]}" "$path"
fi

(( $# == 0 )) || "$this" "${cmd_ar[@]}" -- "$@"
