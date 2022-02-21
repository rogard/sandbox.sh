#! /bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../error_exit"
source "$(dirname "${BASH_SOURCE[0]}")/../rm_blank"

var=$(rm_blank "$1")
# Fails due to nested ','
#var=$(rm_blank $1 | tr '\n' ' ')
arr=()
readarray -t -O 1 arr < <(echo "$var")
len="${#arr[@]}"
(( $len == 0 )) && error_exit $(printf "length zero")
line="${arr[1]}"
patt='^@(.+)\{ *(.+)'
echo "$line" | grep -qE "$patt"; exit_code="$?"
(( exit_code == 0 ))\
    ||  error_exit $(printf "%s head not match %s" "$line" "$patt")
IFS=$'\t' read format id < <(echo "$line" | sed -E "s/$patt/\1\t\2/")
patt=','
echo "$format" | grep -qE "$patt"; tail_comma="$?"
#arr[0]="$format"
arr[1]="$id"
# tail
line="${arr[$len]}"
patt='^(.*)} *$'
echo "$line" | grep -qE "$patt"; exit_code="$?"
(( exit_code == 0 ))\
    ||  error_exit $(printf "%s tail not match %s" "$line" "$patt")
IFS= read tail < <(echo "$line" | sed -E "s/$patt/\1/")
#echo "$len"
tail=$(rm_blank <(echo "$tail"))
if
    [[ -z "$tail" ]]
then
    (( len-- ))
else
    arr["$len"]="$tail"
fi

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
#printf '%s\t' "${arr[@]:0:$len}"
printf '%s\t' "${arr[@]}"
