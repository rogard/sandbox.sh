#! /usr/bin/env bash
# =========================================================================
# file_uid.sh                                  Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:    ./file_uid.sh <target_root> <file> ...
# Semantics: using generated uid for <file>, creates by default <target_root>\
#            /uid/{file,.info/stat}; repeats with the next file.
# Options:
#     Syntax                     Default          $1         $2
#     --copy=true|false          true
#     --rename=true|false        false
#     --uid-gen=<command; ...>   cksum0x.sh "$1"; <file>
#     --info-dir=<string>        .info            
#     --info-do=<commad; ...>                     <info-dir> <target-stat>
# Use case: find <source> -type f -print0 | xargs -0 ./file_uid.sh <target>
# =========================================================================
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$bash_source")
source "$this_dir"/error_exit
uid_gen="$this_dir"'/cksum0x.sh "$1";'

bool_copy=0
bool_rename=1
info_dir='.info'

help()
{
    sed -n '/^# ===/,/^# ===/p' "$this"
}

operands=()
while (( ${#} > 0 ))
do
    case ${1} in
        ( '--help' ) help; exit 0;;
        ( '--uid-gen='* ) uid_gen="${1#*=}";;
        ( '--info-dir='* ) info_dir="${1#*=}";;
        ( '--info-do='* ) info_do="${1#*=}";;
        ( '--copy='* )
        case ${1#*=} in
            ( 'false' ) bool_copy=1;;
            ( 'true' ) bool_copy=0;;
            ( * ) error_exit "$this" "Wrong value for --copy=";;
        esac
        ;;
        ( '--rename='* )
        case ${1#*=} in
            ( 'false' ) bool_rename=1;;
            ( 'true' ) bool_rename=0;;
            ( * ) error_exit "$this" "Wrong value for --copy=";;
        esac
        ;;
        ( '-'* ) error_exit "$this" "Wrong option" "$1";;
        ( * ) operands+=( "$1" );;
    esac
    shift
done
set -- "${operands[@]}"

[[ -d "$1" ]] || error_exit "$0 expects a directory; got $1"

target_root="$1"
shift

[[ -f "$1" ]] || error_exit "$0 expects a file; got $1"

path="$1"
shift

id=$("$SHELL" -c "$uid_gen" "$SHELL" "$path")\
    || error_exit "$this->$id"
target_dir="$target_root/$id"
target_info="$target_dir/$info_dir"
target_stat="$target_info/stat"
target_path="$target_dir"/$(basename "$path")

mkdir -p "$target_info"\
    && touch "$target_stat"\
    && grep -vf "$target_stat" <(stat "$path") >> "$target_stat"

[[ -z "$info_do" ]] || "$SHELL" -c "$info_do" "$SHELL" "$target_info" "$target_stat"

if
    (( bool_copy == 0 ))
then

    mapfile -d '' array < <(find "$target_dir" -maxdepth 1 -type f -size +0 -print0)
    for other_path in "${array[@]}"
    do
        other_id=$("$SHELL" -c "$uid_gen" "$SHELL" "$other_path") || error_exit "$this->$other_id"
        
        if [[ $other_id == $id ]]
        then
            if (( bool_rename == 0 ))
            then
                [[ "$other_path" == "$target_path" ]] || mv "$other_path" "$target_path"
            fi
            bool_copy=1 # cancel copy
            break
        fi
    done    
    if (( bool_copy == 0 ))
    then
        cp "$path" "$target_dir"
    fi
fi

(( $# == 0 )) || "$this" "$target_root" "$@"
