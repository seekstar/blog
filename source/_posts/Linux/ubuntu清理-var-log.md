---
title: ubuntu清理/var/log
date: 2021-01-31 10:44:45
tags:
---

参考：<https://askubuntu.com/questions/239455/how-do-i-stop-var-log-kern-log-1-from-consuming-all-my-disk-space/239491>

```shell
sudo rm /var/log/kern* &>/dev/null
sudo rm /var/log/messages* &>/dev/null
```
这些好像基本上是被备份的dmesg。
