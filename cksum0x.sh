#! /usr/bin/env bash
# =========================================================================
# cksum0x.sh                                   Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:      ./cksum0x.sh <file> ...
# Output:      hexa of cksum of <file>
# =========================================================================
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$this")
source "$this_dir"/error_exit

help()
{
    echo "Syntax: cksum0x.sh <file> ..."
    echo "Also see: source file"
    echo
}

operands=()
while (( $# > 0 ))
do
    case ${1} in
        ( '--help' ) help; exit 0;;
        ( '-*' )
        error_exit "$this receives uknown option ${1}"
        exit 1;;
        *) operands+=("${1}");;
    esac
    shift
done
set -- "${operands[@]}"

[[ -f "${1}" ]] || error_exit $(printf "%s\n" "$this expects a file;" "got: ${1}")

file_path="${1}"
shift

cksum "$file_path"\
    | awk 'BEGIN{FS=" ";}{print $1;}'\
    | xargs printf "%x\n"

(( $# == 0 )) || "$this" "$@"
