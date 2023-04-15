---
title: CentOS升级
date: 2023-04-14 12:26:22
tags:
---

升级有风险，建议先备份数据。

## `8`升级到`8-stream`

{% post_link Distro/'USTC-mirror将CentOS-8升级为stream' %}

## `8-stream`升级到`9-stream`

先将原先的repos备份：

```shell
mv /etc/yum.repos.d /etc/yum.repos.d-$(date +%Y.%m.%d.%H:%M:%S.%N)
```

然后再指定新的源。以TUNA镜像源为例：

```shell
mkdir /etc/yum.repos.d

# tuna
mirror=https://mirrors.tuna.tsinghua.edu.cn/centos-stream
# aliyun
# mirror=https://mirrors.aliyun.com/centos-stream

cat > /etc/yum.repos.d/centos.repo <<EOF
[baseos]
name=CentOS Stream \$releasever - BaseOS
baseurl=$mirror/\$stream/BaseOS/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[appstream]
name=CentOS Stream \$releasever - AppStream
baseurl=$mirror/\$stream/AppStream/\$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF

cat > /etc/yum.repos.d/centos-addons.repo <<EOF
[extras-common]
name=CentOS Stream \$releasever - Extras packages
baseurl=$mirror/SIGs/\$stream/extras/\$basearch/extras-common/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Extras-SHA512
EOF
```

然后将`$releasever`设置为`9`，将`$stream`设置为`9-stream`:

```shell
# https://donghao.org/2015/04/30/the-value-of-releasever-for-yum/
echo 9 > /etc/yum/vars/releasever
echo 9-stream > /etc/yum/vars/stream
```

```shell
yum makecache
```

这时可能会报这种错：`nothing provides module(platform:el8) needed by module virt:rhel:8080020230131213515:fd72936b.x86_64`。这些module都是过时的，我们直接reset这些module即可:

```shell
# https://ahelpme.com/linux/centos-stream-9/dnf-install-and-conflicting-requests-nothing-provides-moduleplatformel8-needed-by-module/
yum module reset virt
```

然后升级：

```shell
# https://dnf.readthedocs.io/en/latest/command_ref.html#distro-sync-command
# https://dnf.readthedocs.io/en/latest/conf_ref.html
# --allowerasing: 允许删除在新版本repo中不存在的包
# deltarpm=false: 关闭差量传输
sudo yum distro-sync --allowerasing --setopt=deltarpm=false
# https://bugzilla.redhat.com/show_bug.cgi?id=1960991
rpmdb --rebuilddb
```

注意，CentOS 9 stream创建的XFS分区会引入与旧内核不兼容的新特性：<https://bugzilla.redhat.com/show_bug.cgi?id=2046431>。不过从CentOS 8 stream升级到CentOS 9 stream不会导致在已有的分区中引入该新特性。

### epel

```shell
# /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
yum install epel-release

# tuna
mirror=https://mirrors.tuna.tsinghua.edu.cn/epel
# aliyun
# mirror=https://mirrors.aliyun.com/epel

cat > /etc/yum.repos.d/epel.repo <<EOF
[epel]
name=Extra Packages for Enterprise Linux \$releasever - \$basearch
baseurl=$mirror/\$releasever/Everything/\$basearch/
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-\$releasever

[epel-debuginfo]
name=Extra Packages for Enterprise Linux \$releasever - \$basearch - Debug
baseurl=$mirror/\$releasever/Everything/\$basearch/debug/
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-\$releasever
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux \$releasever - \$basearch - Source
baseurl=$mirror/\$releasever/Everything/source/tree/
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-\$releasever
gpgcheck=1
EOF

cat > /etc/yum.repos.d/epel-next.repo <<EOF
[epel-next]
name=Extra Packages for Enterprise Linux \$releasever - Next - \$basearch
baseurl=$mirror/next/\$releasever/Everything/\$basearch/
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-\$releasever

[epel-next-debuginfo]
name=Extra Packages for Enterprise Linux \$releasever - Next - \$basearch - Debug
baseurl=$mirror/next/\$releasever/Everything/\$basearch/debug/
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-\$releasever
gpgcheck=1

[epel-next-source]
name=Extra Packages for Enterprise Linux \$releasever - Next - \$basearch - Source
baseurl=$mirror/next/\$releasever/Everything/source/tree/
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-\$releasever
gpgcheck=1
EOF

yum update --allowerasing
```

### 事务测试失败

```text
  file /usr/share/ruby/irb from install of rubygem-irb-1.3.5-160.el9.noarch conflicts with file from package ruby-irb-2.5.9-107.module_el8.4.0+847+ee687b6c.noarch
```

好像`sudo yum remove ruby-irb`就行了。

相关：<https://forums.centos.org/viewtopic.php?t=50923>

### grub2-editenv：错误： 无效的环境块

```shell
# https://gist.github.com/illucent/c3be9da2b87d79a22112436b93642c9b
# https://www.cnblogs.com/5201351/p/17134924.html
grub2-editenv /boot/grub2/grubenv create
```

## 参考文献

[Centos-Stream-8升级Centos-Stream-9教程](https://zhuanlan.zhihu.com/p/571394959)
