---
title: "git解决sign_and_send_pubkey: signing failed: agent refused operation"
date: 2020-01-27 14:21:40
---

deepin中使用git时，经常在push时会报错：

```shell
searchstar@searchstar-PC:~/git/tools$ git push gitee 
sign_and_send_pubkey: signing failed: agent refused operation
Permission denied (publickey).
fatal: 无法读取远程仓库。

请确认您有正确的访问权限并且仓库存在。
```

ubuntu中如果把默认名的私钥文件（id_rsa）改成其他名字（如id_rsa_git）后，也会报这个错。
一般情况下，执行以下两条命令即可

```shell
eval "$(ssh-agent -s)"
ssh-add
```

但是这样会多出一个ssh-agent的进程，而且终端关闭后也不会终止。

一个更好的解决方案是在~/.ssh下添加一个名为config的文件，内容如下：

```
Host gitee.com
	User git
	IdentityFile ~/.ssh/id_rsa_git
```

其中id_rsa_git是给git用的私钥文件名。
