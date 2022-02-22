#! /bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../error_exit"
source "$(dirname "${BASH_SOURCE[0]}")/../rm_blank"

help()
{
    printf "s%\n%s\n%s\n%s\n"\
    "Same as bib_fields_base.sh, but:"\
    "- small cap keys"\
    "- values enclosed by { and }"
    printf "s%\n%s\n%s\n"\
    "Syntax: bib_fields.sh [-h|--help] file"\
    "options:"\
    "h     Print this Help."
}
