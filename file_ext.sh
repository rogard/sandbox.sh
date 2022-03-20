#! /usr/bin/env bash
# =========================================================================
# file_ext.sh                                  Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:    - ./file_ext.sh <target> <file.ext> ...
# Semantics: - Copies the directory containing <file.ext> to <target>/<ext>
# Options:            Default
#   --depth=<integer> 1
#   --no-ext=<string> no-ext
# Status: ** not tested **
# =========================================================================
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$bash_source")
source "$this_dir"/error_exit 

depth=1

help()
{
    sed -n '/^# ===/,/^# ===/p' "$this"
}

options=()
operands=()
while (( ${#} > 0 ))
do
    case ${1} in
        ( '--'* )
        option="${1}"
        options+=( "${option}" )
        case ${option} in
            ( '--help') help; exit 0;;
            ( '--depth='* ) "${1#*=}";;
        esac
        ;;
        ( '-'* ) error_exit "$this" "Wrong option" "$1";;
        ( * ) operands+=( "$1" );;
    esac
    shift
done
set -- "${operands[@]}"

[[ -d "$1" ]] || error_exit "$this expects a directory; got $1"

target_root="$1"
shift

[[ -f "$1" ]] || error_exit "$this expects a file; got $1"

source_file="$1"
shift

ext="${source_file##*.}"
[[ -n $ext ]] || ext='no-ext'

target="$target_root/$ext"
mkdir -p "$target"
source=$(dirname "$source_file")

(( $depth==1 )) || error_exit "$this" "only depth=1 is implemented;
 got " "$depth"

cp -r "$source" "$target"

(( $# == 0 )) || "$this" "${options[@]}" "$@"
