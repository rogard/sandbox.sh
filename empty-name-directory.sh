#! /bin/bash

help()
{
    printf "%s %s\n%s\n%s\n%s\n\n" "Puts in target directory, "\
    "inventory of empty files and within, "\
    "matching directories;"\
    "matches are saved using markdown links [basename of directory](path to directory);"\
    "writes to stdout prexisting empty files in target directory (residue)."
    printf "%s\n%s\n%s\n"
    "Syntax: inventorempty.sh [-h|--help] source_directory target_directory"
    "options:"
    "h     Print this Help."
    
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
source_dir="$1"
target_dir="$2"

find "$target_dir" -maxdepth 1 -type f\
 | while IFS= read -r path;\
    do 
>"$path"
    done

find "$source_dir" -type f -empty\
    | while IFS= read -r path
do
    dir=$(dirname "$path")
    base=$(basename "$path")
    target="$target_dir/$base.md"
    printf "%s\n" "[${dir##*/}]($dir)" >> "$target"
done

# residue=$(find "$target_dir" -type f -empty -print0) # BUG
 residue=$(find "$target_dir" -type f -empty -print)

if
    [[ -z "$residue" ]]
then
:
else
#    echo "$residue" | xargs -0 -n1 -- basename
    echo "$residue" | while IFS= read - path; do printf "%s" "$path\n"; done
fi
