---
title: 搭建NFS
date: 2024-12-13 15:12:49
tags:
---

## 宿主机

```shell
sudo apt install nfs-kernel-server
```

假设要把`$server_dir`暴露给NFS的client，那么要把它的owner变成`nobody`，group变成`nogroup`：

```shell
sudo mkdir -p $server_dir
sudo chown nobody:nogroup $server_dir
```

`/etc/exports`:

```text
$server_dir    client_ip(rw,sync,no_subtree_check,all_squash)
```

文档：`man exports`

`client_ip`可以是单个IP，也可以是CIDR：<https://askubuntu.com/a/998736>

```text
all_squash
       Map all uids and gids to the anonymous user. Useful for NFS-exported public FTP  directories,  news
       spool directories, etc. The opposite option is no_all_squash, which is the default setting.
```

```shell
sudo systemctl reload nfs-kernel-server
```

如果有防火墙的话需要对`client_ip`放开2049端口。

## 客户端

```shell
sudo apt install nfs-common
```

假设要把宿主机上的`$server_dir` mount到`$mount_dir`上：

```shell
sudo mkdir -p $mount_dir
sudo mount host_ip:$server_dir $mount_dir
```

如果需要开机自动mount，在`/etc/fstab`里加入：

```shell
host_ip:$server_dir	$mount_dir	nfs4	defaults,nofail	0	0
```

## 存在的问题：

- NFS需要客户端的IP来做访问控制。这样如果客户端没有固定IP的话就不行。而且IP很容易伪造，所以只能在局域网里用。

- NFS默认的security option是`sec=sys`，只使用Linux的UID和GID。但是同一个用户在多台机器上的uid和gid可能是不一样的。所以当多台机器上的同一个用户的UID不一样时，挂载同一个NFS的时候会出现同一个文件的owner和group在不同机器上不一样。为了避免这种情况，我们只好使用`all_squash`，把所有文件的owner和
都设置成anonymous user。其实理论上NFSv4可以支持idmap，在不同机器上把user和group翻译到机器上对应的UID和GID。但是需要配置Kerberos：<https://serverfault.com/questions/745225/creating-a-nfs-share-across-servers-with-varying-uids>。

## 参考文献

<https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-20-04>
