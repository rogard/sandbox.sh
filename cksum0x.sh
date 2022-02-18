#!/bin/bash

help()
{
   echo "Hexa of cksum of file's content"
   echo
   echo "Syntax: cksum0x.sh [-h|--help] file "
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
            printf "%s\t%s\n" "$1" $(cat "$1" | cksum | awk 'BEGIN{FS=" ";}{print $1;}' | xargs printf "%x")
            shift # past argument
            ;;
    esac
done
