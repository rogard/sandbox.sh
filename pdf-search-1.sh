# !/bin/bash
# source "$(dirname "${BASH_SOURCE[0]}")/../error_exit"

help()
{
   echo "Search inside pdf's first page."
   echo
   echo "Syntax: pdf-search-1 [-h|t] directory pattern "
   echo "options:"
   echo "h     Print this Help."
   echo "t     Output formatted as a table."
   echo "stdout:"
   echo path filename found
   echo
}

#printf "%s\n" "This script searches inside pdfs' first page,"
#printf "%s\n" "and writes it to stdout using tab as the separator."
#printf "%s\n"\
#       "In what directory would you like to search?"
#read str
#echo "str=$str"
#read -a ar <<< "$str"
dir="$1"
patt="$2"

##printf "%s\n" "----"
#
find "$dir"/* -type f -name '*pdf'\
    | while IFS= read -r path;\
    do #id="${path##*/}";\
       found=$(pdftotext -l 1 -f 1 "$path" - | grep -im1 "$patt");\
       [[ -z "$found" ]] || printf "%s\t%s\n" "$path" "$found";\
    done
