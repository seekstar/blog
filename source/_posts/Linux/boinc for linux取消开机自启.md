---
title: boinc for linux取消开机自启
date: 2020-03-10 11:38:34
---

参考：<https://askubuntu.com/questions/96787/stop-boinc-from-auto-start-on-system-boot>

```shell
sudo systemctl disable boinc-client
```
缺点是这样做了之后，手动打开Boinc-Manager也不能正常运行。
如果要重新使用boinc，只能
```shell
sudo systemctl enable boinc-client
```
然后重启。
