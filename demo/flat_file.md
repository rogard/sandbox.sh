# Flat filing using a unique ID

Create files with redundancies:
```
"$SHELL" << EOF
export w_dir="$HOME"'/Desktop'
rm -r "$w_dir"/{source,target}
mkdir -p "$w_dir"/{source,target}
export source="$w_dir"/source
export target="$w_dir"/target
echo "1" > "$source"/foo
echo "2" > "$source"/bar.x
cp "$source"/bar.x "$source"/bar.y
tar -czf "$source"/ar.tar.gz -C "$source" foo
ls "$source"
EOF
```
Flat file these files using uid
```
$ find "$source" -type f -print0\
  | xargs -0 './recursextract_do.sh' './file_uid.sh '"$target"'  "$1"'
```
Check the results
```
/home/er/Desktop/target
├── f9e91852
│   ├── bar.y
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
f9e91852
     1	/home/er/Desktop/source/bar.y
     2	/home/er/Desktop/source/bar.x
fb80eddb
     1	/home/er/Desktop/source/foo
     2	/tmp/tmp.JvmGroBzcE/foo
```
Paths by ext:
```
$  mkdir -p "$w_dir/ext"
$ ./file_ext.sh "$w_dir/ext" "$target/f9e91852/bar.y"
$ tree -a "$w_dir/ext"
/home/er/Desktop/ext
└── y
    └── f9e91852
        ├── bar.y
        └── .info
            └── stat

3 directories, 2 files
```
