#!/bin/bash
# source "$(dirname "${BASH_SOURCE[0]}")/../error_exit"

help()
{
   echo "Search inside pdf's first page."
   echo
   echo "Syntax: pdf-search-1.sh [-h|--help] directory pattern "
   echo "options:"
   echo "h     Print this Help."
   echo "stdout:"
   echo path found
   echo
}

## https://stackoverflow.com/a/14203146/9243116
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

dir="$1"
patt="$2"

find "$dir"/* -type f -name '*pdf'\
    | while IFS= read -r path;\
    do #id="${path##*/}";\
        found=$(pdftotext -l 1 -f 1 "$path" - | grep -im1 "$patt");\
        [[ -z "$found" ]] || printf "%s\t%s\n" "$path" "$found";\
    done
