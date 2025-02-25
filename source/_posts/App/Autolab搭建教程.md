---
title: Autolab搭建教程
date: 2024-03-24 16:54:48
tags:
---

主要照着官方文档配置：<https://docs.docker.com/compose/install/linux/#install-using-the-repository>

这里主要讲一些坑点。

## SSL

官方教程：<https://docs.autolabproject.com/installation/docker-compose/#configuring-tlsssl>

### (not working) autolab自带的证书申请机制

```shell
sudo ./ssl/init-letsencrypt.sh
```

报错：

```text
  Detail: 47.74.9.105: Fetching http://autolab.db.iiis.io/.well-known/acme-challenge/fCaVWPv4jdINFSnaBILQ4RToTJRZc1aiTrUed2ZOlyQ: Connection refused
```

但是宿主机80和443都开着。

结论：自带的SSL证书申请不work。

### 在宿主机申请SSL证书

用acme申请，网上有很多教程，这里不再赘述。

acme需要在宿主机运行nginx并监听80端口。一种比较简单的方法是直接让autolab的container的443端口映射到宿主机的443，宿主机的nginx不监听443。

另一种方法是在宿主机上的nginx监听443，把autolab的container的443映射到一个随机端口，然后让宿主机的nginx把访问autolab域名的https流量转发给autolab监听的端口：

```text
server {
	listen 443 ssl;
	listen [::]:443 ssl;
	server_name autolab域名;
	ssl_certificate /root/.acme.sh/autolab域名_ecc/fullchain.cer;
	ssl_certificate_key /root/.acme.sh/autolab域名_ecc/autolab域名.key;
	client_max_body_size 0;
	location / {
		proxy_pass https://localhost:autolab端口;
		proxy_set_header Host autolab域名;
	}
}
```

其中`client_max_body_size 0;`防止附件过大的提交被宿主机nginx拦截。

注意：不要把autolab配置成不使用ssl的同时在外面套一层SSL，因为这样tango和autolab之间的通信会出问题。可能是因为tango往autolab发消息仍然使用的http，然后被外面的nginx拒绝。

## 发送邮件

### gmail

绑定手机号开启两步验证，然后就可以创建app password了。

### Amazon SES

一定要申请production mode。sandbox模式下只能发信给指定地址。只有production mode才能发信给任意地址：<https://repost.aws/knowledge-center/ses-554-400-message-rejected-error>

### (不推荐) sendgrid

不知道为什么注册不了。而且帐号过一段时间不用就不能再用了：<https://stackoverflow.com/questions/68056093/sendgrid-mails-are-always-in-pending-status>

## autograder要安装pkill

需要在Dockerfile里`apt install -y procps`

不然会报这个错：

```shell
Autodriver: Unable to exec at line 277: No such file or directory
Autodriver: Error killing user processes at line 365
```

## `Tango/config.py`

更改了之后重启docker即可生效：

```shell
sudo docker compose stop
sudo docker compose up -d
```

### 改大`VM_ULIMIT_USER_PROC`

`VM_ULIMIT_USER_PROC`默认100，太小了。改大一些：

```py
VM_ULIMIT_USER_PROC = 10000
```

太小的话分配太多`std::async`会失败，然后似乎会fall back到单线程模式。

### `VM_ULIMIT_FILE_SIZE`

如果autograde的时候报了这个错：

```shell
Error running link command: SIGXFSZ
```

说明编译产生的文件大小超限了。在`Tango/config.py`里把`VM_ULIMIT_FILE_SIZE`设置大一些（默认100MiB）

注意，`VM_ULIMIT_FILE_SIZE`似乎是用32 bit integer存的，所以值一定要小于4G，不然会溢出。

## 使用教程

{% post_link App/'Autolab使用教程' %}
