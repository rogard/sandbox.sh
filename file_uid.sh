#! /usr/bin/env bash
# =========================================================================
# file_uid.sh                                  Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:    ./file_uid.sh <target_dir> <file> ...
# Semantics: uid:= 'uuid-gen file'; creates the following:
#            <target_dir>/uid/{file,.info/stat}
#            Repeats with the next file.
# Options:   Syntax                      Default
#            --copy=true|false
#            --uuid-gen='<command; ...>'  cksum0x.sh
#            --info-name=<string>  .info
# Use case:  find <source> -type f -print0 | xargs -0 ./file_uid.sh <target>
# =========================================================================
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$bash_source")
source "$this_dir"/error_exit
uid_gen="$this_dir/cksum0x.sh "'$1'

# "$SHELL" -c "$uid_gen" "$SHELL" "$2"

bool_copy=1
info_name=".info"

help()
{
    echo "Syntax: file_uid.sh <target_dir> <file> ..."
    echo "Also see: source file"
}

operands=()
while (( ${#} > 0 ))
do
    case ${1} in
        ( '--help' ) help; exit 0;;
        ( '--uid-gen='* ) uid_gen="${1#*=}";;
        ( '--info-name='* ) info_name="${1#*=}";;
        ( '--copy='* )
        case ${1#*=} in
            ( 'false' ) bool_copy=1;;
            ( 'true' ) bool_copy=0;;
            ( * ) error_exit "$this" "Wrong value for --copy=";;
        esac
        ;;
        ( '-'* ) error_exit "$this" "Wrong option" "$1";;
        ( * ) operands+=( "$1" );;
    esac
    shift
done
set -- "${operands[@]}"

# printf "%s\n" "$@"

[[ -d "$1" ]] || error_exit "$0 expects a directory; got $1"

target_dir="$1"
shift

[[ -f "$1" ]] || error_exit "$0 expects a file; got $1"

path="$1"
shift

id=$("$SHELL" -c "$uid_gen" "$SHELL" "$path") || error_exit "$this->$id"

target_id="$target_dir/$id"
target_info="$target_id/$info_name"
target_stat="$target_info/stat"

mkdir -p "$target_info"\
    && touch "$target_stat"\
    && grep -vf "$target_stat" <(stat "$path") >> "$target_stat"

if
    (( bool_copy == 0 ))\
        || [[ -z $(find "$target_id" -maxdepth 1 -type f -print -quit) ]]
then
    cp "$path" "$target_id"
fi

(( $# == 0 )) || "$this" "$target_dir" "$@"
