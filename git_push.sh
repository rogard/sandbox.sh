#! /usr/bin/env bash
# =========================================================================
# git_push.sh                                  Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:      ./git_push username password
# Credits:     https://stackoverflow.com/a/27702513/9243116
# =========================================================================
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$this")
source "$this_dir"/error_exit

help()
{
    sed -n '/^# ===/,/^# ===/p' "$this"
}

options=()
operands=()
while (( ${#} > 0 ))
do
    case ${1} in
        ( '--'* )
        option="${1}"
        options+=( "${option}" )
        case ${option} in
            ( '--help') help; exit 0;;
        esac
        ;;
        ( '-'* ) error_exit "$this" "Wrong option" "$1";;
        ( * ) operands+=( "$1" );;
    esac
    shift
done
set -- "${operands[@]}"

(( $# == 2 )) || error_exit "$this" "expects username pass;" "got $@"

user="$1"
pass="$2"

expect - <<_END_EXPECT
    spawn git push
    expect "User*"
    send "$user\r"
    expect "Pass*"
    send "$pass\r"
    set timeout -1   # no timeout
    expect eof
_END_EXPECT
