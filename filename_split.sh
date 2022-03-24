#! /usr/bin/env bash
# =========================================================================
# filename_ext.sh                              Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:    ./filename_ext.sh <source>
# Output:    prefix extension
# Options:   
#   --pattern-list=<file>
#   --delimiter=<char>
# =========================================================================
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$bash_source")
source "$this_dir"/error_exit 

pattern_list="$this_dir"/aux/filename_ext
delimiter='\0'

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
            ( '--pattern-list='* ) pattern_list="${1#*=}";;
            ( '--delimiter='* ) delimiter="${1#*=}";;
        esac
        ;;
        ( '-'* ) error_exit "$this" "Wrong option" "$1";;
        ( * ) operands+=( "$1" );;
    esac
    shift
done
set -- "${operands[@]}"

[[ -f "$1" ]] || error_exit "$this expects a file; got $@"

source_file="$1"
shift

basen=$(basename "$source_file")

prefix="$basen"

ext=''
if [[ $basen =~ ^[^.]+\. ]]
then
    candidate_ext="${basen##*.}"
    grep -qf "$pattern_list" <<< "$candidate_ext"
    if (( $? == 0 ))
    then
        prefix="${basen%%.*}"
        ext="$candidate_ext"
    fi
fi
    
printf "%s$delimiter" "$prefix" "$ext"

(( $# == 0 )) || "$this" "${options[@]}" "$@"
