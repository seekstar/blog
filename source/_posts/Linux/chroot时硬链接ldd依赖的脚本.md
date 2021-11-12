---
title: chroot时硬链接ldd依赖的脚本
date: 2020-06-06 18:32:41
tags:
---

chroot_ln_file.sh
```shell
#!/bin/bash

mkdir -p $(dirname $2/$1)
ln $1 $2/$1 &> /dev/null
ori=$(readlink $1)
if [ -n "$ori" ]; then
	real=$(realpath -s $ori)
	if [[ "$real" == "$ori" ]]; then
		$0 $real $2
	else
		$0 $(dirname $1)/$ori $2
	fi
fi
```

chroot_lnso.sh
```shell
#!/bin/bash

ldd $1 | sed 's/^\s*//g' | sed 's/.* => //g' | sed 's/ (0x.*)//g' | grep '^/' | xargs -i $(dirname $0)/chroot_ln_file.sh {} $2
```

用法：
```shell
sudo bash chroot_ln_file.sh /bin/bash /var/chroot
sudo bash chroot_lnso.sh /bin/bash /var/chroot
```
