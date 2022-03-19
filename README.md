# sandbox.sh

Small bash scripts

## Flat filing using a unique ID

Create dummy files:
```
$ export w_dir="$HOME"'/Desktop'
$ mkdir -p "$w_dir"/{source,target}
$ export source="$w_dir/source"
$ export target="$w_dir/target"
$ echo "1" > "$source/foo"
$ echo "2" > "$source/bar"
$ cp "$source"/bar "$source"/bar2
$ tar -czf "$source"/ar.tar.gz -C "$source" foo
$ ls "$source"
ar.tar.gz  bar  bar2  foo
```
Process these files:
```
$ find "$source" -type f -print0\
| xargs -0 './recursextract.sh' './file_uid.sh '"$target"'  "$1"'
```
Check the results
```
$ tree -a "$target"
/home/er/Desktop/target
├── f9e91852
│   ├── bar2
│   └── .info
│       └── stat
└── fb80eddb
    ├── foo
    └── .info
        └── stat

4 directories, 4 files
```
Paths by uid:
```
$ ./file_uid.sh --print "$target"
* f9e91852
     1	/home/er/Desktop/source/bar2
     2	/home/er/Desktop/source/bar
* fb80eddb
     1	/home/er/Desktop/source/foo
     2	/tmp/tmp.kesHeywEGs/foo
```
