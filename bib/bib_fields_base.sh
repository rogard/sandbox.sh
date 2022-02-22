#--------------------------------#
# Copyright (2022) Erwann Rogard #
#--------------------------------#
#! /bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../error_exit"
source "$(dirname "${BASH_SOURCE[0]}")/../rm_blank"

help()
{
    printf "%s\n"\
           "File containing bib entry --> tab separated:"\
           "- type"\
           "- identifier"\
           "- remaining fields; "
    printf "%s\n"\
           "keys --> lowercase(keys);"\
           "\"value\" --> {value}." 
}

# https://stackoverflow.com/a/14203146/9243116
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]];
do
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
patt=' *?(.+[^= ]) *= *(.+) *'
if (( $tail_comma == 0 ))
then
patt='^'"$patt"', *$'
else
patt='^ *,'"$patt"'$'
fi
patt_bis='^[^ ].+[^ ]=(\{.+\}|".+")$'
for (( i = 2; i <= $len; i++ ))
do
    line="${arr[$i]}"
    echo "$line" | grep -qE "$patt"; exit_code="$?"
    (( exit_code == 0 ))\
        ||  error_exit $(printf "%s field does match %s" "$line" "$patt")
    line=$(echo "$line" | sed -E "s/$patt/\1=\2/")
    echo "$line" | grep -qE "$patt_bis"; exit_code="$?"
    (( exit_code == 0 ))\
        ||  error_exit $(printf "%s field does match %s" "$line" "$patt_bis")
    field_key=$(echo "$line" | sed -E 's/^(.+)=.+$/\1/' | tr '[:upper:]' '[:lower:]')
    field_value=$(echo "$line" | sed -E 's/^(.+)=.(.+).$/\{\2\}/')
    arr["$i"]=$(echo "$field_key=$field_value")
done

printf '%s\t' "$entry_type"
printf '%s\t' "${arr[@]:1:$len}"
