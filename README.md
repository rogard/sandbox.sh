# sandbox.sh

Small bash scripts

## Use case \#1

Check whether a file is compressed; if so, extract and recurse; otherwise file it using a uid. The created directory contains customizable info about any file matching that uid.
```
find <source> -type f -print0\
    | xargs -0 ./recursextract.sh ./file_uid.sh <target> --
```
