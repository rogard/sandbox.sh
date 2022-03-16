#! /usr/bin/env bash
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$this")
source error_exit

help()
{
    echo "Syntax: ./rec_extract_do.sh [arg1...] -- path1 ..."
    printf "%s " "Semantics: if path,"\
           "if it is itself *tar.gz, then recurses,"\
           "otherwise executes 'script [arg1...] file'"
}

ante_args=()
while (( $# > 0 ));
do
    case $1 in
        -h|--help)
            help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
#            echo "\$1=$1"
            ante_args+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

if
    (( $# == 0 ))
then
    exit 0
fi

# echo "${ante_args[@]}"

path="$1"
shift

if
    [[ $path =~ .tar.gz$ ]]
then

    # <div>
    # https://stackoverflow.com/a/53063602/9243116
    dir_tmp=$(mktemp -d)

    [[ -d "$dir_tmp" ]] || error_exit "$this" "$dir_tmp"

    trap "exit 1"           HUP INT PIPE QUIT TERM
    trap 'rm -rf "$dir_tmp"' EXIT
    # </div>

    tar -xvzf "$path" --directory="$dir_tmp" 1>/dev/null

    find "$dir_tmp" -type f -print0 | xargs -0 "$this" "$ante_args" --

else
    "$ante_args" -- "$path"
fi

(( $# == 0 )) || "$this" "$ante_args" -- "$@"
