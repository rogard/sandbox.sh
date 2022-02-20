#! /bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../error_exit"

#head=$(cat "$1" | head -n 1)
#patt='^@(.+)\{(.+)'
#var=$(echo "$head" | grep -qE "$patt"); exit_code="$?"
#(( exit_code == 0 ))\
#    ||  error_exit $(printf "%s head not match %s" "$head" "$patt")
#arr=()
#readarray -td'	' arr < <(echo "$head" | sed -E "s/$patt/\1\t\2/")
#format="${arr[0]}"
#id="${arr[1]}"
#printf "format=%s\nid=%s\n" "$format" "$id"
#tail=$(cat "$1" | tail -n 1)

