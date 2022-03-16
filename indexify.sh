#! /usr/bin/env bash
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$bash_source")
source "$this_dir"/error_exit
index_gen="$this_dir"/cksum0x.sh

rename=1

help()
{
    echo "Syntax: indexify.sh target_dir file1 ..."
    echo "Example: find source_dir -type f -print0 | xargs -0 ./indexify.sh target_dir"
}

positional_args=()
while (( $# > 0 ))
do
    case $1 in
        -h|--help)
            help
            exit 0
            ;;
        --rename)
            shift
            rename=0
            ;;        
        *)
          positional_args+=("$1") # save positional arg
          shift # past argument
            ;;
    esac
done
set -- "${positional_args[@]}"

[[ -d "$1" ]] || error_exit "$1 is not a directory"

target_dir="$1"
shift

[[ -f "$1" ]] || error_exit "$1 is not a file"

path="$1"
shift

value=$("$index_gen" "$path")
target_value="$target_dir/$value"
target_info="$target_value/.info"
target_stat="$target_info/stat"

mkdir -p "$target_info"\
    && touch "$target_stat"\
    && stat "$path" >> "$target_stat"

if
    (( rename == 0 ))\
        || [[ -z $(find "$target_value" -maxdepth 1 -type f -print -quit) ]]
then
    cp "$path" "$target_value"
fi

 (( $# == 0 )) || "$this" "$target_dir" "$@"
