#! /bin/bash
bin_dir="${BASH_SOURCE[0]}"
source $(dirname "$bin_dir")/error_exit

help()
{
   echo "pdf compression using ghostscript"
   echo
   echo "Syntax: pdf-compress.sh [-h|--help] file "
   echo "options:"
   echo "h     Print this Help."
   echo
}

# https://stackoverflow.com/a/14203146/9243116
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]
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

ext="${1#*.}"
if
    [[ "$ext"==pdf ]]
then
    size_display="$bin_dir/filesize.sh -lh $1"
    out="${$1%.pdf}.gs.pdf"    
    ghostscript -sDEVICE=pdfwrite\
                -dCompatibilityLevel=1.4\
                -dPDFSETTINGS=/ebook\
                -dNOPAUSE -dQUIET -dBATCH\
                -sOutputFile="$out"\
                "$1"
    ratio=$("$bin_dir"/filesize.sh "$out")
    ratio/=$("$bin_dir"/filesize.sh "$1")
    printf "%s\t%s" "$size" "$ratio"
else
    error_exit "$1 is not a pdf"
done
