#! /bin/bash

help()
{
    printf "%s %s %s\n %s\n %s\n\n"\
           "Puts in target directory,"\
           "inventory of empty files and within,"\
           "matching directories;"\
           "matches are saved using markdown links [directory](path to directory);"\
           "writes to stdout files in target directory that remain empty."    
    printf "%s\n\n" "Syntax: empty-name-directory.sh [-h|--help] source_directory target_directory"
    printf "%s\n%s\n" "options:" "h     Print this Help."
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
    empty="${path##*/}"
    dir=$(dirname "$path")
    base=$(basename "$dir")
    target="$target_dir/$empty.md"
    touch "$target"
    printf "%s\n" "[$base]($source_dir/$base)" >> "$target"
done

#residue=$(find "$target_dir" -type f -empty -print0) # BUG
residue=$(find "$target_dir" -type f -empty -print)

if
    [[ -z "$residue" ]]
then
    :
else
    echo "$residue"\
        | while IFS= read -r path
    do
        printf "%s\n" $(basename "$path")
    done
fi
