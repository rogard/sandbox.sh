#! /usr/bin/env bash
## file_using_index.sh [--do file] path
## 

dirname_bash_source=$(dirname "${BASH_SOURCE[0]}")
source "$dirname_bash_source"/error_exit
# https://unix.stackexchange.com/a/163126/142980

help()
{
    echo "Syntax: file_using_index.sh [-h|--help] [--do file1] file2\tstring"
    echo ""
    echo "|Var    | definition        | default            |"
    echo "+-------+-------------------+--------------------+"
    echo "|do_file| file1             |file_using_index_do |"
    echo "|source | file2             |                    |"
    echo "|index  | string            |                    |"
    echo "|dir    | dirname $source   |                    |"
    echo "|base   | basename $source  |                    |"
    echo ""
    echo "for each line in exec:"
    echo "1. fun <-- line"
    echo "2. fun dir base index"
    echo ""
}

do_file="$dirname_bash_source"/file_using_index_do
positional_args=()
while (( $# > 0 ))
do
    case $1 in
        -h|--help)
            help
            exit 0
            ;;
        --do)
            shift
            do_file=$1
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

(( $# == 2 )) ||\
    error_exit $(printf "Expecting 2 positional argument, instead: %s" "$#")

source="$1"
index="$2"
dir=$(dirname "$source")
base=$(basename "$source")

source "$do_file"

_do "$dir" "$base" "$index"
