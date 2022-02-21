#! /bin/bash
##! /usr/bin/bash env

help()
{
   echo "Hexa of cksum of file's content"
   echo
   echo "Syntax: batchemail.sh [-h|--help] "
   echo "options:"
   echo "h     Print this Help."
   echo
}

export SUBJ="FRANCE: on whistleblowers, the ombudsman, and Eva Joly"
export SENT="sent"
touch "$SENT"
export PREFIX='/home/er/dev/bash/script/job-12/out/whistlbill_'

sed 's/TITLE/$title/g; s/"\($\||\)/\1/g

error_exit()
{
    echo "Exiting because: $1"
    exit 1
}

echo "*********************"
echo "Batch sending email for"
printf "Subject: %s\n" "$SUBJ"

ask=0
while IFS=$'\t' read -r -u3 hex name addr title
do
    printf "%s\n" "-------"
    path="$PREFIX$hex.pdf"
    body=$(cat "$template" | sed "s/TITLE/$title/" | sed "s/NAME/$name/")
    printf 'hex:%s\nname:%s\nto:%s\ntitle:%s\npath:%s\nbody:%s\n'\
           "$hex" "$name" "$addr" "$title" "$path" "$body";
    
    while [[ $ask != 1 ]]
    do
        echo "ask=$ask"
        read -p ">Go ahead?" answer
        case $answer in
            [y]* ) break;;
            [n]* ) exit;;
            [a]* ) export ask=1; break;;
            * ) echo "Try again using y|n|s";;
        esac
    done

    sent=$(grep "$hex" "$SENT")
    [  -n "$sent" ] && printf ">Skipping, alreay sent.\n" && continue
    [  -f "$path" ] || error_exit "path missing"
    
    if ! 
       echo "$body" | mutt -d 2\
                           -s "$SUBJ"\
                           -a "$path"\
                           -- "$addr"
    then
        printf "%s\t%s\t%s\t%s\n" "$hex" "$name" "$addr" "$title" >> "$SENT";
    fi
done 3< recipient
