---
title: centos端口转发
date: 2021-08-14 19:41:48
---

比方说监听本地的```23333```端口，将数据都转发到```10.249.40.227```的22端口上，可以这样：

```shell
sudo yum install nmap-ncat
ncat --sh-exec "ncat 10.249.40.227 22" -l 23333 --keep-open
```

如果要后台运行：

```shell
nohup ncat --sh-exec "ncat 10.249.40.227 22" -l 23333 --keep-open &
```

然后查看一下```23333```端口是否开放了：

```shell
sudo firewall-cmd --zone=public --list-ports
```

如果里面有```23333/tcp```，就说明开放了，否则需要这样开放端口：

```shell
sudo firewall-cmd --zone=public --add-port=23333/tcp --permanent
sudo firewall-cmd --reload
```

参考文献：
[Linux端口转发的几种常用方法](https://www.cnblogs.com/xiaozi/p/13553765.html)
[Centos7开放及查看端口](https://www.cnblogs.com/heqiuyong/p/10460150.html)
