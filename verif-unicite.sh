# !/bin/bash

working_dir="../identifiant"
verification="../verification.log"
touch "$verification"

current_date_time="`date "+%Y-%m-%d %H:%M:%S"`"
echo "$current_date_time" | tee -a "$verification"
echo "Vérification unicité fichier non vide pour chaque identifiant, hormis *md" | tee -a "$verification"

found=$(find "$working_dir" -mindepth 2 -maxdepth 2 -type f -size +0c -print | grep -vE '.+\.md')
head=$(echo "$found" | awk 'NR==1')
check=$(dirname $head)
rest=$(echo "$found" | awk 'FNR>1')
aucune_infraction=0
while read path && tmp=0;
do
    dir=$(dirname "$path")
    if [[ $dir == $check ]]
    then
        tmp=1
        if
            (( $aucune_infraction==0 ))
        then
            aucune_infraction=1
            echo ". En infraction:" | tee -a "$verification"
        fi
        printf "%s\n" "${dir##*/}" 
    fi
    check="$dir"
done < <(echo "$rest")
if
    (( $aucune_infraction == 0 ))
then  
    echo ": OK"
fi |  tee -a  "$verification"
