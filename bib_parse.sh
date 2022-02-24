#! /bin/bash
dirname_bash_source=$(dirname "${BASH_SOURCE[0]}")
source "$dirname_bash_source/error_exit"
source "$dirname_bash_source/check_string"
source "$dirname_bash_source/rm_blank"
source "$dirname_bash_source/rm_empty_lines"
source "$dirname_bash_source/rm_latex_comment"

help()
{
    printf "%s\n"\
           "Takes as input a file containing one bib entry, and by default outputs line by line:"\
           "- entry type"\
           "- identifier"\
           "- remaining fields."\
           ""
    printf "%s\n"\
           "Syntax: bib_parse.sh [-h|--help] file"\
           "options:"\
           "- h     Print this Help."\
           "- b     Format as bib entry."\
           ""\
           "Requirement on file:"
    printf "%s\n"\
           "@[entry type]{[identifier],"\
           "    key={value},"\
           "       .     "\
           "       .     "\
           "       .     "\
           "    key={value},"\
           "    key={value}"\
           "}"\
           ""\
           "Variants:"
    printf "%s\n"\
           "- upper case key"\
           "- lead spacing and surrounding '='"\
           "- blank lines before/after"\
           "- trailing %.+"\
           "- lines begining with %"\
           "- no trailing comma for [identifier] and leading ',' for all fields."\
           ""\
           "Example:" 
    printf "%s\n"\
           "bib_parse.sh aux/knuth1984.bib'"\
    ""
    printf "%s\n"\
           "Warning: option -b will not restore latex comments (%)"\
           ""
}

# https://stackoverflow.com/a/14203146/9243116
POSITIONAL_ARGS=()
bibify=1
while [[ $# -gt 0 ]]; do
  case $1 in
      -h|--help)
          help
          exit 0
      ;;
      -b|--bib)
          bibify=0
          shift # past argument
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
    arr[0]="$id"
else
    error_exit $(printf "head='%s' does not match '%s'" "$head" "$patt")
fi

# *** closing '}'
patt='^}$'
(( closing_line_num = $len-1 ))
tail="${arr[$closing_line_num]}"
[[ $tail =~ $patt ]]\
    || error_exit $(printf "tail='%s' does not match '%s'" "$tail" "$patt")

# *** tail-comma
patt_middle='([^ ]+) *= *\{(.+)\}'
patt_versat="^ *[,]?$patt_middle[,]?(\s*%.*)?$"
(( i_bound=len-1 ))
if (( tail_comma==0 ))
then
    patt='^[^,]+=.+,$'
    (( i_bound-- ))
else
    patt='^ *,[^,]+=.+$'
fi
lhs()
{
    echo "$1" | sed -E "s/$2/\1/" | tr '[:upper:]' '[:lower:]'
}
rhs()
{
    echo "$1" | sed -E "s/$2/{\2}/"
}

for (( i = 1; i < $i_bound; i++ ))
do    
    line="${arr[$i]}"
    if [[ $line =~ $patt ]]
    then
        lhs=$(lhs "$line" "$patt_versat")
        rhs=$(rhs "$line" "$patt_versat")
        arr["$i"]=$(echo "$lhs=$rhs")
    else
        printf "Checking comma:\n line=%s does not match %s " "$line" "$patt"
        exit 1
    fi
done
if
    (( tail_comma==0 ))
then
    patt='^ *[^,]+=.+\}$'
    line="${arr[$i_bound]}"
    if [[ $line =~ $patt ]]
    then
        lhs=$(lhs "$line" "$patt_versat")
        rhs=$(rhs "$line" "$patt_versat")
        arr["$i_bound"]=$(echo "$lhs=$rhs")
        (( i_bound++ )) #pkoi?
    else
        printf "Checking comma:\n line=%s does not match %s " "$line" "$patt"
        exit 1
    fi    
fi

if (( bibify==0 ))
then
    readarray -t arr < <("${BASH_SOURCE[0]}" $1)
    printf "@$entry_type{%s,\n" "${arr[1]}"
    printf "    %s,\n" "${arr[@]:2:(( $i_bound - 2 ))}"
    printf "    %s\n" "${arr[(( $i_bound ))]}"
    printf "}\n"
else
    printf '%s\n' "$entry_type"
    printf '%s\n' "${arr[@]:0:$i_bound}"
fi
