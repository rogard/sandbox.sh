#! /usr/bin/env bash
# =========================================================================
# recursextract_do.sh                          Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:    ./recursextract_do.sh <command list;> <path> ...
# Semantics: if applicable extracts from archive and recurses, else
#            executes user-supplied command; repeats with the next path.
# Use case:
# $ find <source directory> -type f -size +0 -print0\
#    | xargs -0 './recursextract_do.sh' './file_by_uid.sh\
#    --info-do+='\''find "$(dirname "${1}")"\
#    -size 0 -exec cp {} "${2}" \;'\''\
#    '<target dir>' "$1";'
# =========================================================================

this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$this")
source "$this_dir"/error_exit

help()
{
    sed -En '/^# ====/,/^# ====/p' "$this" 
}

operands=()
while IFS=; (( $# > 0 ))
do
    case ${1} in
        ( '--help' ) help; exit;;
        ( * ) operands+=("${1}"); shift;;
    esac
done
set -- "${operands[@]}"

if (( $# < 2 ))
   then
   error_exit\
       $(printf "%s\n"\
       ""\
       "$this expects at least two arguments; "\
       "got: '$@'")
fi

command_list="${1}"
shift

path="$1"
shift

if
    [[ ${path} =~ (\.tar.*|\.zip)$ ]]
then
    # <div>
    # https://stackoverflow.com/a/53063602/9243116
    dir_tmp=$(mktemp -d)

    [[ -d "$dir_tmp" ]] || error_exit "$this" "$dir_tmp"

    trap 'error_exit "$this" "$@"' HUP INT PIPE QUIT TERM
    trap 'rm -rf "$dir_tmp"' EXIT
    # </div>

    case ${path} in 
        ( *'.tar'*) tar -xvzf "${path}" --directory="$dir_tmp" 1>/dev/null;;
        ( *'.zip') unzip -d "$dir_tmp" "${path}" 1>/dev/null;;
        ( * )
    esac

    find "$dir_tmp" -type f -print0 | xargs -0 -r "$this" "$command_list" "$@"

else
    "$SHELL" -c "$command_list" "$SHELL" "${path}"
fi

(( $# == 0 )) || "$this" "$command_list" "$@"
