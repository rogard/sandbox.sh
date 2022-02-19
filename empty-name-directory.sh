#! /bin/bash

help()
{
    echo "Puts in target directory, "
    echo "inventory of empty files and within, "
    echo "matching directories;"
    echo "matches are saved using markdown links [directory](path to directory);"
    echo "writes to stdout prexisting empty files in target directory (residue)."
    echo 
    echo "Syntax: inventorempty.sh [-h|--help] source_directory target_directory"
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
source_dir="$1"
target_dir="$2"

find "$target_dir" -maxdepth 1 -type f\
 | while IFS= read -r path;\
    do 
>"$path"
    done

find "$source_dir" -type f -empty\
    | while IFS= read -r path
    do empty="${path##*/}";
       dir=$(dirname "$path");
       base="${dir##*/}"
       target="$target_dir/$empty.md"
       printf "%s\n" "[$base]($source_dir/$base)" >> "$target"
done

find "$target_dir" -maxdepth 1 -type f\
 | while IFS= read -r path;\
    do 
>"$path"
    done

residue=$(find "$target_dir" -type f -empty -print0)

if
    [[ -z "$residue" ]]
then
    echo ""
else
    echo "Residue:"
    echo "----"
    echo "$residue" | xargs -0 -n1 -- basename
fi
