#! /usr/bin/env bash
bash_source="${BASH_SOURCE[0]}"
dir_bash_source=$(dirname "$bash_source")
source error_exit

help()
{
    echo "Syntax: ./rec_extract_do.sh script name.tar.gz "
    printf "%s " "Semantics: for each file extracted from name.tar.gz,"\
           "if it is itself *tar.gz, then recurses,"\
           "otherwise executes 'script file'"    
}

# https://stackoverflow.com/a/14203146/9243116
POSITIONAL_ARGS=()
while (( $# > 0 ));
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

(( $# > 1 )) || error_exit "Expecting > 1 arguments, got $@"

script="$1"
shift

compressed_file="$1"
shift

# <div>
# https://stackoverflow.com/a/53063602/9243116
dir_tmp=$(mktemp -d)

[[ -d "$dir_tmp" ]] || error_exit "temp dir fail"

trap "exit 1"           HUP INT PIPE QUIT TERM
trap 'rm -rf "$dir_tmp"' EXIT
# </div>

#echo "$compressed_file"

tar -xvzf "$compressed_file" --directory="$dir_tmp" 1>/dev/null

find "$dir_tmp" -type f -print0 | grep -zEv '\.tar\.gz$' | xargs -0 -I {} "$script" {}

find "$dir_tmp" -type f -print0\
    | grep -zE '\.tar\.gz$'\
    | xargs -0 -I {} "$bash_source" "$script" {}

(( $# == 0 )) || "$bash_source" "$script" "$@"
