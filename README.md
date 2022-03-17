# sandbox.sh

Small bash scripts

Use case \#1:
```
find <source> -type f -print0\
    | xargs -0 ./recursextract.sh ./file_uid.sh <target> --
```
