# sandbox.sh

Small bash scripts

## Use case \#1

Check whether a file is compressed; if so, extract and recurse; otherwise created in `<target> a directory named `uid` containing a copy of that file and customizable info that is updated each time a file matches that uid.
```
find <source> -type f -print0\
    | xargs -0 ./recursextract.sh ./file_uid.sh <target> --
```
