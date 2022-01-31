---
title: debian man命令
date: 2022-01-31 13:38:40
tags:
---

```shell
apt-file search -x "/usr/bin/man$"
```

```
man-db: /usr/bin/man
```

所以

```shell
sudo apt install man-db
```
