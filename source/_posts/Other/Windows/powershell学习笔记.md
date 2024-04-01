---
title: powershell学习笔记
date: 2020-03-26 21:39:21
---

参考：<http://www.bubuko.com/infodetail-1259207.html>

## 脚本后缀名

powershell的脚本后缀名是`ps1`。`bat`是cmd的后缀名。

原文：<https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-7.4>

## 报错：`在此系统上禁止运行脚本`

### 查看execution policy

```powershell
Get-ExecutionPolicy
```

#### `Restricted`

Windows 客户端计算机的默认执行策略。

允许单个命令，但不允许脚本。

阻止运行所有脚本文件，包括格式和配置文件 (.ps1xml)、模块脚本文件 (.psm1) 和 PowerShell 配置文件 (.ps1)。

#### `RemoteSigned`

Windows 服务器计算机的默认执行策略。

在本地计算机上编写且不是从 Internet 下载的脚本不需要数字签名。

需要受信任的发布者对从 Internet 下载的脚本和配置文件（包括电子邮件和即时消息程序）的数字签名。

### 更改execution policy

以管理员身份打开PowerShell，执行命令：

```powershell
set-executionpolicy remotesigned
```

### 原文

[Windows “在此系统上禁止运行脚本”解决办法](https://www.cnblogs.com/yummylucky/p/14846557.html)

<https://learn.microsoft.com/zh-cn/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4>

## Linux命令

windows的powershell支持了许多linux命令。与linux中使用方法基本相同的有：ls，rm、cat等。仍不支持的有touch、grep等。

与linux中使用方法不同的有：

### mv和cp

mv移动文件，cp复制文件。与linux不同的是，只能接收两个参数，第一个是原文件名或目录名，第二个参数是目的目录名或文件名。

### diff

参考：<https://blog.csdn.net/sxzlc/article/details/104880426>

要用cat把文件内容提取出来再比较

```shell
diff (cat a) (cat b)
```

