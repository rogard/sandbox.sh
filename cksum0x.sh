#! /usr/bin/env bash
# =========================================================================
# cksum0x.sh                                   Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:     ./cksum0x.sh <file>
# Output:     hexa of cksum of <file>
# =========================================================================
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$this")
source "$this_dir"/error_exit

help()
{
    echo "Syntax: cksum0x.sh <file> "
    echo "Also see: source file"
    echo
}

operands=()
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
            operands+=("$1")
            shift
            ;;
    esac
done

set -- "${operands1[@]}"

(( $# == 1 )) ||\
    error_exit $(printf "Expecting 1 positional argument, instead: %s\t" "$@")

[[ -f "$1" ]] ||\
    error_exit $(printf "Expecting a file for  %s" "$1")

file_path="$1"
shift

index=$(cat "$file_path" | cksum | awk 'BEGIN{FS=" ";}{print $1;}' | xargs printf "%x\n")

printf "$index"
