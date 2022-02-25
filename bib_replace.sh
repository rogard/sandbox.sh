#! /bin/bash
dirname_bash_source=$(dirname "${BASH_SOURCE[0]}")
source "$dirname_bash_source/error_exit"
source "$dirname_bash_source/bib_field_replace"

help()
{
    printf "%s\n"\
           "Syntax: bib_replace.sh [-h|--help] template entry_1.bib ..."\
           "options:"\
           "- h     Print this Help."\
           "- b     Format as bib entry."\
           ""\
           ""
           "Example:" 
    printf "%s\n"\
           "bib_replace.sh aux/bib_replace aux/knuth1984.bib'"\
           ""
}

# https://stackoverflow.com/a/14203146/9243116
POSITIONAL_ARGS=()
bibify=1
while (( $# > 0 )); do
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

template="$1"
shift # past argument

bib_entry="$1"
echo "$bib_entry"
#while IFS=$'\t' read -r func field replace;
readarray lines < "$template"
lines_count="${#lines[@]}"
for (( i = 0; i < $lines_count; i++ ))
do    
    readarray arr < <(echo "${lines[$i]}")
    echo "${#arr[@]}"    
done

#do
#    echo "${#arr[@]}"
##    "${arr[2]}"
##    "$func" "$field" "$replace" "$bib_entry";
#done < "$template"
