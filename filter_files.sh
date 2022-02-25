#! /bin/bash
dirname_bash_source=$(dirname "${BASH_SOURCE[0]}")
source "$dirname_bash_source"/error_exit

help()
{
    printf "%s\n"\
           "Example"\
           "./filter_files.sh '@book|@report' file_in 'month=' file_out"\
           "./filter_files.sh '@book|@report' file_in -v 'month=' file_out"\
           ""\
           "options:"\
           "-v    Invert match"\
           ""
}

count="$#"
echo "$count"

POSITIONAL_ARGS=()
while (( $# > 0 )); do
    case $1 in
        -h|--help)
            help
            exit 0
            ;;
        -v)
            if
                (( $# == 2 ))
            then
                invert_match=0
                shift # past argument
            else
                error_exit "-v should be in 3rd position"
            fi
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

#touch "$4"
>"$4"
while IFS= read -r path;
do
    grep -qE "$1" "$path";
    if (( $?==0 ))
    then
        grep -qE "$3" "$path";
        if (( $?==0 || invert_match==0 ))
        then
            echo "$path" >> "$4";
        fi
    fi   
done < "$2"
