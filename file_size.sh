#!/bin/bash
# source "$(dirname "${BASH_SOURCE[0]}")/../error_exit"

help()
{
    echo "Syntax: filesize.sh [-h|--help] [-b|-blocksize [K|M|G]] path"
    echo
}

# https://stackoverflow.com/a/14203146/9243116
POSITIONAL_ARGS=()
HUMAN=false
while [[ $# -gt 0 ]];
do
    case $1 in
        -h|--help)
            help
            exit 0
            ;;
        --human)
            HUMAN=true
            shift # past argument
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

# https://linuxhandbook.com/show-file-size-linux/
do="ls -l"
[[ "$HUMAN" == true ]] && do+="h"
do+=" $1"
echo $(eval $do) | awk 'BEGIN{FS=" ";}{print $5;}'    
