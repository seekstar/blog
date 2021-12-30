---
title: flatpak install Can't create temporary directory
date: 2021-12-30 20:52:23
tags:
---

可能是```/tmp```和```/var/tmp```的权限出问题了。检查一下它们的权限：

```shell
stat /tmp
stat /var/tmp
```

正常情况下，它们都应该是```1777```，如果不是，就用```chmod```改成```1777```：

```shell
chmod 1777 /tmp
chmod 1777 /var/tmp
```

来源：<https://www.reddit.com/r/linuxmint/comments/b0lszg/problems_while_installing_a_flatpak/>
