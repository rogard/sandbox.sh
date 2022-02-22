#! /bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../error_exit"
source "$(dirname "${BASH_SOURCE[0]}")/../rm_blank"

help()
{
    printf "s%\n%s\n%s\n%s\n"\
    "Takes as input a file containing one bib entry, and outputs tab separated:"\
    "- entry type"\
    "- identifier"\
    "- remaining fields"
    printf "s%\n%s\n%s\n"\
    "Syntax: bib_fields_base.sh [-h|--help] file"\
    "options:"\
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

arr=()
# nested, forbids:
# readarray -t -O 1 arr < <(rm_blank "$1" | tr '\n' ' ')
readarray -t -O 1 arr < <(rm_blank "$1")
len="${#arr[@]}"
(( $len == 0 )) && error_exit $(printf "length zero")
line="${arr[1]}"
patt='^@(.+)\{ *(.+)'
echo "$line" | grep -qE "$patt"; exit_code="$?"
(( exit_code == 0 ))\
    ||  error_exit $(printf "%s head not match %s" "$line" "$patt")
IFS=$'\t' read entry_type id < <(echo "$line" | sed -E "s/$patt/\1\t\2/")
patt=','
echo "$entry_type" | grep -qE "$patt"; tail_comma="$?"
#arr[0]="$entry_type"
arr[1]="$id"
# tail
line="${arr[$len]}"
patt=' *}$'
echo "$line" | grep -qE "$patt"; exit_code="$?"
(( exit_code == 0 ))\
    ||  error_exit $(printf "%s tail not match %s" "$line" "$patt")
(( len -- ))

# rest
patt=' *?(.+[^= ]) *= *(\{.+\}) *'
if (( $tail_comma == 0 ))
then
patt='^'"$patt"', *$'
else
patt='^ *,'"$patt"'$'
fi   
for (( i = 2; i <= $len; i++ ))
do
    line="${arr[$i]}"
    echo "$line" | grep -qE "$patt"; exit_code="$?"
    (( exit_code == 0 ))\
        ||  error_exit $(printf "%s field does match %s" "$line" "$patt")
    arr["$i"]=$(echo "$line" | sed -E "s/$patt/\1=\2/g")
done

printf '%s\t' "$entry_type"
(( len_bis = len-1 ))
printf '%s\t' "${arr[@]:1:$len_bis}"
printf '%s' "${arr[$len]}"
