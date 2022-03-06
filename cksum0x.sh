#!/bin/bash
dirname_bash_source=$(dirname "${BASH_SOURCE[0]}")
source "$dirname_bash_source"/error_exit

help()
{
    echo "Syntax: cksum0x.sh [-h|--help] file_path "
    echo "Output: Hexa of cksum of file_path's content"
    echo "What for? For what a unique identifier may be for"
    echo
}

# https://stackoverflow.com/a/14203146/9243116
positional_args=()
while (( $# > 0 ))
do
    case $1 in
        -h|--help)
            help
            exit 0
            ;;
        -d|--delimiter)
            shift
            delimiter=$1
            shift
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            positional_args+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

set -- "${positional_args[@]}"

(( $# == 1 )) ||\
    error_exit $(printf "Expecting 1 positional argument, instead: %s\t" "$@")

[[ -f "$1" ]] ||\
    error_exit $(printf "Expecting a file for  %s" "$1")

file_path="$1"

index=$(cat "$file_path" | cksum | awk 'BEGIN{FS=" ";}{print $1;}' | xargs printf "%x\n")

printf "$index"
