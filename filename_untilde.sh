#! /usr/bin/env bash
# =========================================================================
# filename_untilde.sh                          Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:    ./filename_untilde.sh <file.ext~> ...
# Options:                 Default
#   --incl-dir=true|false  true
# Use case:
# $ find <source> -maxdepth 2 -type f -size +0 -print0\
#    | grep -z '~'\
#    | xargs -0 -n 1 "$SHELL" -c\
#    '{ new_path=$(./filename_untilde.sh "$1"); mv "$1" "$new_path"; }'\
#    "$SHELL"
# =========================================================================
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$bash_source")
source "$this_dir"/error_exit 

bool_dir=0

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
            ( '--incl-dir='* )
            case ${1#*=} in
                ( 'false' ) bool_dir=1;;
                ( 'true' ) bool_dir=0;;
                ( * ) error_exit "$this" "Wrong: --incl-dir=" "${1#*=}";;
            esac
            ;;
        esac
        ;;
        ( '-'* ) error_exit "$this" "Wrong option" "$1";;
        ( * ) operands+=( "$1" );;
    esac
    shift
done
set -- "${operands[@]}"


[[ -f "$1" ]] || error_exit "$this expects a file; got $1"

source_file="$1"
shift

dirn=$(dirname "$source_file")
basen=$(basename "$source_file")

#TODO
# [[ $basen =~ \~ ]] || issue warning

out=''
(( bool_dir == 0 )) && out+="$dirn/"
out+="${basen/\~/}"

echo "$out"

(( $# == 0 )) || "$this" "${options[@]}" "$@"
