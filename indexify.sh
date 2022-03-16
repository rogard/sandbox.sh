#! /usr/bin/env bash
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$bash_source")
source "$this_dir"/error_exit
index_gen="$this_dir"/cksum0x.sh

bool_copy=1

help()
{
    echo "Syntax: indexify.sh [--copy=true|false] target_dir file1 ..."
    printf "%s\n"\
           "Semantics:  "\
           "- Assigns file1 a unique value"\
           "- Makes target_value:=target_dir/value,"\
           "- Updates target_value/.info/stat"\
           "- Checks if a file is in target_value otherwise copies it"\
           "- Repeats for the next file"
    echo "Example: find source_dir -type f -print0 | xargs -0 ./indexify.sh target_dir"
    printf "Options: %s\n"\
           "--bool_copy	Always copies"
    printf "%s\n"\
           "TODO"\
           "--index=..."\
           "Append only diff stat"
}

operands=()
while (( ${#} > 0 ))
do
    case ${1} in
        ( '--help' ) help; exit 0;;
        ( '--copy='* )
        case ${1#*=} in
            ( 'false' ) bool_copy=1;;
            ( 'true' ) bool_copy=0;;
            ( * ) error_exit "$this" "Wrong value for --copy=";;
        esac
        ;;
        ( * ) operands+=( "$1" );;
    esac
    shift
done
set -- "${operands[@]}"

(( bool_copy == 0 )) || echo "don't copy"

#[[ -d "$1" ]] || error_exit "$1 is not a directory"
#
#target_dir="$1"
#shift
#
#[[ -f "$1" ]] || error_exit "$1 is not a file"
#
#path="$1"
#shift
#
#value=$("$index_gen" "$path")
#target_value="$target_dir/$value"
#target_info="$target_value/.info"
#target_stat="$target_info/stat"
#
#mkdir -p "$target_info"\
#    && touch "$target_stat"\
#    && stat "$path" >> "$target_stat"
#
#if
#    (( bool_copy == 0 ))\
#        || [[ -z $(find "$target_value" -maxdepth 1 -type f -print -quit) ]]
#then
#    cp "$path" "$target_value"
#fi
#
# (( $# == 0 )) || "$this" "$target_dir" "$@"
