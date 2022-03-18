# sandbox.sh

Small bash scripts

## Use case \#1

Check whether a file is compressed; if so, extract and recurse; otherwise create in `<target>` a directory named `<uid>` containing by default a copy of that file and `<info>` that is updated each time a file matches that uid. 
```
find <source> -type f -print0\
    | xargs -0 ./recursextract.sh './file_uid.sh <target> "$1"'
```
Tracking file duplicates:
```
$ for uid in \<target\>/*;\
do printf "%s\n" "$(basename $uid)"; \
sed -n '/File:/p' "$uid/.info/stat"\
| cut -c 9-\
| tr "\n" "\0"\
| xargs -0 printf \
"    - %s\n"; done
```

