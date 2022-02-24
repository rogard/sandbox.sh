#! /bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/error_exit"
source "$(dirname "${BASH_SOURCE[0]}")/check_string"
source "$(dirname "${BASH_SOURCE[0]}")/rm_blank"
source "$(dirname "${BASH_SOURCE[0]}")/rm_empty_lines"
source "$(dirname "${BASH_SOURCE[0]}")/rm_latex_comment"

help()
{
    printf "%s\n"\
           "Takes as input a file containing one bib entry, and outputs tab separated:"\
           "- entry type"\
           "- identifier"\
           "- remaining fields."\
           ""
    printf "%s\n"\
           "Syntax: bib_parse.sh [-h|--help] file"\
           "options:"\
           "- h     Print this Help."\
           ""\
           "Requirement on file:"
    printf "%s\n"\
           "@[entry type]{[identifier],"\
           "    key = {value},"\
           "        .      "\
           "        .      "\
           "        .      "\
           "    key = {value},"\
           "    key = {value}"\
           "}"\
           ""\
           "Variants:"
    printf "%s\n"\
           "- lead spacing and surrounding '='"\
           "- blank lines before/after"\
           "- no trailing comma for [identifier] and leading ',' for all fields."\
           ""\
           "Example:" 
    printf "%s\n"\
           "bib_parse.sh aux/knuth1984.bib'"    
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
#source_dir="$1"
#target_dir="$2"

arr=()
readarray -t arr < <(rm_empty_lines < "$1" | rm_latex_comment)
len="${#arr[@]}"

# *** head
head="${arr[0]}"
patt_base='@(.+)\{(.+)'
patt='^'"$patt_base"'$'
if
    [[ $head =~ $patt ]]
then
    tail_comma=1 # (false)
    if
        [[ $head =~ ^.+,$ ]]
    then
        tail_comma=0
        patt='^'"$patt_base"',$'
    fi   
    IFS=$'\t' read entry_type id <\
       <(echo "$head"\
             | sed -E "s/$patt/\1\t\2/")
else
    error_exit $(printf "head='%s' does not match '%s'" "$head" "$patt")
fi

# *** closing '}'
patt='^}$'
(( line_num = $len-1 ))
tail="${arr[$line_num]}"
[[ $tail =~ $patt ]]\
    || error_exit $(printf "tail='%s' does not match '%s'" "$tail" "$patt")

# *** tail-comma
patt_middle='([^ ]+) *= *\{(.+)\}'
patt_versat="^ *[,]?$patt_middle[,]?$"
(( i_bound=len-1 ))
if (( tail_comma==0 ))
then
    patt='^[^,]+=.+,$'
    (( i_bound-- ))
else
    patt='^ *,[^,]+=.+$'
fi
for (( i = 2; i < $i_bound; i++ ))
do
    line="${arr[$i]}"
    if [[ $line =~ $patt ]]
    then
        arr["$i"]=$(echo "$line" | sed -E "s/$patt_versat/\1={\2}/")
    else
        printf "Checking comma:\n line=%s does not match %s " "$line" "$patt"
        exit 1
    fi
done
if
    (( tail_comma==0 ))
then        
    patt='^[^,]+=.+[^,]$'
    line="${arr[$i_bound]}"
    if [[ $line =~ $patt ]]
    then
        arr["$i_bound"]=$(echo "$line" | sed -E "s/$patt_versat/\1={\2}/")
        echo "${arr[$i_bound]}"
    else
        printf "Checking comma:\n line=%s does not match %s " "$line" "$patt"
        exit 1
    fi    
fi

patt_key='([^= ]+)'
patt_value='\{([^}]+)\}'
patt_equal=' *= *'
patt_middle="$patt_key""$patt_equal""$patt_value"
patt_head='^ *'
patt_tail=' *$'
if(( tail_comma==0 ))
then
    patt='^ *'"$patt_base"',$'
    patt="$patt_head""$patt_middle"','"$patt_tail"
    (( len_bis = len - 2 ))
else
    patt="$patt_head"','"$patt_middle""$patt_tail"
    (( len_bis = len - 1 ))
fi
#this_do()
#{
#    line="${arr[$i]}"
#    if (( tail_comma==0 )) && (( $i < $len-1 ))
#    then
#        if [[ $line =~ "^.+,^" ]]
#        arr["$i"]=$(echo "$line" | sed -E "s/ /\1={\2}/g")
#
#          
#    then
#        arr["$i"]=$(echo "$line" | sed -E "s/$patt/\1={\2}/g")
#    else
#        printf "field=%s does not match %s " "$line" "$patt"
#        exit 1
#    fi
#}
##for (( i = 1; i < $len_bis; i++ ))
#do
#    this_do
#done
#
#if (( tail_comma==0 ))
#then
#    (( i=len-1 ))
#    patt='^ *'"$patt_base"'$'
#    this_do
#fi
#
#printf '%s\t' "$entry_type"
#(( len_bis = len-2 )) #pkoi?
#printf '%s\t' "${arr[@]:0:$len_bis}"
