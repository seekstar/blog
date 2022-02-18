---
title: 清华源Certificate verification failed
date: 2022-01-23 14:48:59
tags:
---

```text
$ sudo apt update
Err:1 https://mirrors.tuna.tsinghua.edu.cn/debian bullseye InRelease
  Certificate verification failed: The certificate is NOT trusted. The certificate issuer is unknown. The name in the certificate does not match the expected.  Could not handshake: Error in the certificate verification. [IP: 2402:f000:1:400::2 443]
```

根据清华源的[Debian 镜像使用帮助](https://mirrors.tuna.tsinghua.edu.cn/help/debian/)，需要先使用 http 源并安装：

```shell
sudo apt install apt-transport-https ca-certificates
```

但是我将`/etc/apt/sources.list`里的`https`都改成`http`之后，还是会报错：

```text
$ sudo apt update
Get:1 http://mirrors.tuna.tsinghua.edu.cn/debian bullseye InRelease [283 B]
Err:1 http://mirrors.tuna.tsinghua.edu.cn/debian bullseye InRelease                 
  Clearsigned file isn't valid, got 'NOSPLIT' (does the network require authentication?)
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
E: The repository 'http://mirrors.tuna.tsinghua.edu.cn/debian bullseye InRelease' is no longer signed
```

其实还需要在`/etc/apt/apt.conf`里放宽安全限制：

```text
APT{
	Ignore{
		"gpg-pubkey";
	};
	Get{
		AllowUnauthenticated "1";
	};
};
Acquire::Check-Valid-Until false;
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
APT::Get::AllowUnauthenticated "true";
APT::Install-Recommends "false";
APT::Ignore::gpg-pubkey;
Acquire::ForceIPv4 "true";
```

然后

```shell
sudo apt update
sudo apt install apt-transport-https ca-certificates
```

搞定之后再把`/etc/apt/sources.list`和`/etc/apt/apt.conf`还原，再`sudo apt update`即可。

感谢TUNA 技术群`#tuna:matrix.org`里的`@juliandroske:matrix.org`大佬的指点。
