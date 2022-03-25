#! /usr/bin/env bash
# =========================================================================
# file_uid.sh                                  Copyright 2022 Erwann Rogard
#                                                                  GPL v3.0
# Syntax:    ./file_uid.sh <target> <source> ...
#            ./file_uid.sh --print <target> ...
# Semantics: Files <source> based on its unique identifier, inside <target>;
#            repeats with the next file.
#
# Options:
#  Syntax                         Default          $@
#  --uid-gen=<command; ...>       cksum0x.sh "$1"; <source>
#  --copy=true|false              true
#  --info-dir=<string>            info            
#  --info-do+=<command; ...>                       <source><info-dir>
# Use case:
# $ find '/home/er/Documents/record/BG' -type f -size +0 -print0\
#    | xargs -0 './recursextract_do.sh' './file_by_uid.sh\
#    --info-do+='\''find $(dirname "$1")-size 0 -exec cp {} "$2" \;'\''\
#    '/home/er/uid' "$1";'
# =========================================================================
this="${BASH_SOURCE[0]}"
this_dir=$(dirname "$bash_source")
source "$this_dir"/error_exit
uid_gen="$this_dir"'/cksum0x.sh "$1";'

info_dir='info'
info_do='touch "$2/stat"; grep -vf "$2/stat" <(stat "$1") >> "$2/stat";'
bool_copy=0
target_prefix='prefix'

bool_print=1

help()
{
    sed -n '/^# ===/,/^# ===/p' "$this"
}

print()
{
    target_dir="${1}"
    cp "$source" "$target_dir"
    find "$target_dir" -mindepth 1 -maxdepth 1 -type d -print\
        | while IFS= read uid
    do
        printf "%s\n" $(basename "$uid"); 
        sed -n '/File:/p' "$uid"/.info/stat\
            | cut -c 9-\
            | tr "\n" "\0"\
            | xargs -0 printf "%s\n"\
            | cat -n
    done
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
            ( '--help' ) help; exit 0;;
            ( '--print'* ) bool_print=0; break;;
            ( '--uid-gen='* ) uid_gen="${1#*=}";;
            ( '--info-dir='* ) info_dir="${1#*=}";;
            ( '--info-do+='* ) info_do+="${1#*=}";;
            ( '--copy='* )
            case ${1#*=} in
                ( 'false' ) bool_copy=1;;
                ( 'true' ) bool_copy=0;;
                ( * ) error_exit "$this" "Wrong value for --copy=";;
            esac
            ;;
            ( '--rename='* )
            case ${1#*=} in
                ( 'false' ) bool_rename=1;;
                ( 'true' ) bool_rename=0;;
                ( * ) error_exit "$this" "Wrong value for --copy=";;
            esac
            ;;
        esac
        ;;
        ( '-'* ) error_exit "$this" "Wrong option" "$1";;
        ( * ) operands+=( "$1" );;
    esac
    shift
done
set -- "${operands[@]}"

[[ -d "$1" ]] || error_exit "$this expects a directory; got $1"

target_root="$1"
shift

if (( $bool_print == 0 ))
then
    print "$target_root"
else
    
    [[ -f "$1" ]] || error_exit "$this expects a file; got $1"

#    trap 'error_exit "$this" "args=$@"' EXIT

    source="$1"
    shift

    target_id=$("$SHELL" -c "$uid_gen" "$SHELL" "$source")   
    target_dir="$target_root/$target_id"
    target_info="$target_dir/$info_dir"
    mkdir -p "$target_info"
    [[ -z "$info_do" ]] || "$SHELL" -c "$info_do" "$SHELL" "$source" "$target_info"

    target="$target_dir"
    source_base=$(basename "$source")
    target+="/$target_id"
    mapfile -d '' array < <("$this_dir"/filename_split.sh "$source")
    ext="${array[1]}"
    if
        [[ -z "$ext" ]]
    then
        log="$target_info/log"
        touch "$log"
        printf "%s" $(date --iso-8601=minutes) >> "$log"
        printf "\n%s\n" "Missing or uknown extension" >> "$log"
    else
        target+=".$ext"
    fi
    cp -u "$source" "$target"
fi

(( $# == 0 )) || "$this" "${options[@]}" "$@"
