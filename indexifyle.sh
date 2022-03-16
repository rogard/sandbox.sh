#! /usr/bin/env bash
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$bash_source")
source "$this_dir"/error_exit
id_gen="$this_dir"/cksum0x.sh
bool_copy=1
info_name="info"

help()
{
    echo "Syntax: indexifyle.sh target_dir file1 ..."
    printf "%s "\
           "Semantics: assigns to file1 a unique id; updates target_dir with a directory named after that id, target_id; "\
           "target_id contains:"\
           "a file having the same content as file1, and a directory named 'info'. "\
           "Repeats for the next file."
    echo "Other"
    printf "-%s\n"\
           "Intended use: remove duplicates"\
           ".info"    
    echo "Options:"
    printf "  --%s\n"\
           "copy=       true|false  "\
           "id-gen=     script      cksum0x.sh"\
           "info-name=  script      info"
    echo "Example: find source_dir -type f -print0 | xargs -0 ./indexify.sh target_dir"
}

operands=()
while (( ${#} > 0 ))
do
    case ${1} in
        ( '--help' ) help; exit 0;;
        ( '--id-gen='* ) id_gen="${1#*=}";;
        ( '--info-name='* ) info_name="${1#*=}";;
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
#id=$("$id_gen" "$path")
#target_id="$target_dir/$id"
#target_info="$target_id/$info_name"
#target_stat="$target_info/stat"
#
#mkdir -p "$target_info"\
#    && touch "$target_stat"
# grep -vf "$target_stat" <(stat "$path") >> "$target_stat"
#
#if
#    (( bool_copy == 0 ))\
#        || [[ -z $(find "$target_id" -maxdepth 1 -type f -print -quit) ]]
#then
#    cp "$path" "$target_id"
#fi
#
# (( $# == 0 )) || "$this" "$target_dir" "$@"
