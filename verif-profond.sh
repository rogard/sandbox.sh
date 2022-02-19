# !/bin/bash

working_dir="../identifiant"
verification="../verification.log"
touch "$verification"

current_date_time="`date "+%Y-%m-%d %H:%M:%S"`"
echo "$current_date_time" | tee -a "$verification"
echo "Vérification profondeur (identifiant) = 1" | tee -a "$verification"
found=$(find "$working_dir" -mindepth 2 -type d)
if [[ -z "$found" ]]
then
    echo "OK."
else
    printf  "Infraction:%s\n" "$found"
fi  |  tee -a  "$verification"
