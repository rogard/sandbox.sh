# sandbox.sh

## Install

```
$ git clone https://github.com/rogard/sandbox.sh.git
$ cd sandbox.sh
$ sudo for script in *.sh; do chmod +x "$script"; done
```

## Overview

* `cksum0x.sh` hexa of checksum
* `file_uid.sh` flat file using unique identifier
* `file_ext.sh` flat file using extension
* `recursextract_do.sh` if applicable extracts from archive and recurses, else executes user-supplied command.
