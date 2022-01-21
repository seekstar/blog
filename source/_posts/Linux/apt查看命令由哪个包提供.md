---
title: apt查看命令由哪个包提供
date: 2022-01-21 21:32:33
tags:
---

用```apt-file```查看。

```shell
sudo apt install apt-file
sudo apt-file update
```

搜索```javac```是由哪个包提供的：

```shell
apt-file search -x "javac$"
```

其中```-x```表示使用正则表达式。输出：

```
bash-completion: /usr/share/bash-completion/completions/javac
openjdk-11-jdk-headless: /usr/lib/jvm/java-11-openjdk-amd64/bin/javac
openjdk-8-jdk-headless: /usr/lib/jvm/java-8-openjdk-amd64/bin/javac
```

来源：<https://www.cyberciti.biz/faq/equivalent-of-rpm-qf-command/>
