# !/bin/bash

root=".."
identifiant_dir="$root/identifiant"
target_dir="$root/nombre"
pattern_exclude='@'

[[ -d "$target_dir" ]] || mkdir "$target"

printf "%s\n%s\n"\
       "Ce programme màj $target"

find "$target_dir" -maxdepth 1 -type f | while IFS= read path; do echo "Identifiants:">"$path"; done

>"$info"

find "$identifiant_dir" -mindepth 1 -type d\
    | while IFS= read -r path;\
    do empty_count=$(find "$path" -type f -empty | wc -l);
       id="${path##*/}"
       target="$target_dir/$empty_count.md"
       printf "%s\n" "[$id:]($identifiant_dir/$id)" | tee -a "$target"
    done
     #| sort | uniq | tee "$info"
