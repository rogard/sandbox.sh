#!/bin/bash
# source "$(dirname "${BASH_SOURCE[0]}")/../error_exit"
source_dir=$(dirname "${BASH_SOURCE[0]}")

help()
{
    echo "With target=cksum0x.sh file.ext, "
    echo "copies file to target/target.ext, "
    echo "moves file to file.trash."
    echo 
    echo "Syntax: cksum0x_mv.sh [-h|--help] [-d|--dir] path"
    echo "options:"
    echo "h     Print this Help."
    echo
}

# https://stackoverflow.com/a/14203146/9243116
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
      -h|--help)
          help
          exit 0
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}"

dir=$(dirname "$1")
id=$("$source_dir"/cksum0x.sh "$1" | awk 'BEGIN{FS=" ";}{print $2;}')
target_dir="$dir/$id"
base=$(basename "$1")
ext="${base#*.}"
target_file="$id.$ext"
[[ -d "$target_dir" ]] || mkdir "$target_dir"
cp "$1" "$target_dir/$target_file"
mv "$1" "$1.trash"
