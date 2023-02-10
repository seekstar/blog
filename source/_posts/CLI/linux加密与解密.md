---
title: linux加密与解密
date: 2020-02-22 21:02:30
---

参考：<https://jingyan.baidu.com/article/851fbc371d8c907e1e15ab79.html>

ssh私钥很长，不可能记下来，所以可能需要放入U盘随身携带，但是这样有失窃的风险。所以可以把私钥加密，要用的时候解密即可。

- 加密
```shell
#!/bin/bash

ori=$(pwd)
cd $(dirname $1)
if [ $2 ]; then
	tar -zcf - $(basename $1) | openssl aes256 -salt -md sha256 > $ori/$2
else
	echo Must specify the name of output file
fi
```

- 解密
```shell
#!/bin/bash

if [ $2 ]; then
	cat $1 | openssl aes256 -md sha256 -d | tar zx -C $2
else
	cat $1 | openssl aes256 -md sha256 -d | tar zx
fi
```

参考自：<http://www.chinaoc.com.cn/p/1141270.html>
由于openssl 1.1 版本默认使用的摘要算法是sha256，而1.0默认使用的是md5，所以需要用-md选项指定摘要算法为sha256，防止不能解密不同版本的openssl加密的文件。
