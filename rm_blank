rm_blank()
{
# Related:
#  awk '!/^[[:blank:]]*$/'
# Old:
#  grep '[^[:blank:]]$' < "$1"
   input="${1:-$(</dev/stdin)}"
   echo "$input" |  grep '[^[:blank:]]$'
}