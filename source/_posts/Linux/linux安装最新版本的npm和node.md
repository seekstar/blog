---
title: linux安装最新版本的npm和node
date: 2020-04-03 16:53:54
---

## 先安装旧版本npm

```shell
sudo apt install -y node
```

有些发行版是

```shell
sudo apt install -y npm
```

查看当前版本

```shell
npm -v
```

我的输出是

```
3.5.2
```

是非常老的版本

## 安装最新版node

新版npm可能不支持老版本的node：<https://seekstar.github.io/2021/12/30/npm-does-not-support-node-js-v10-21-0-you-should-probably-upgrade-to-a-newer-version-of-node/>

所以先升级node。

```shell
sudo npm install -g n
sudo n stable
```

我的输出

```
searchstar@searchstar-mint19:~$ sudo n stable

  installing : node-v12.16.1
       mkdir : /usr/local/n/versions/node/12.16.1
       fetch : https://nodejs.org/dist/v12.16.1/node-v12.16.1-linux-x64.tar.xz
   installed : v12.16.1 (with npm 6.13.4)

Note: the node command changed location and the old location may be remembered in your current shell.
         old : /usr/bin/node
         new : /usr/local/bin/node
To reset the command location hash either start a new shell, or execute PATH="$PATH"
```

这里很良心地提示了要重启终端或者执行

```shell
PATH="$PATH"
```

才能使用最新版本

查看现在的node版本

```shell
node -v
```

```
v12.16.1
```

已经是最新版了

## 安装最新npm

可以通过旧版本npm直接安装新版npm

```shell
sudo npm install npm@latest -g
```

非常坑的是，现在立即执行

```shell
npm -v
```

得到的还是旧版本，这是因为此时npm仍然指向旧的npm可执行文件。其实只要重开终端或者执行

```shell
PATH="$PATH"
```

就可以更新npm命令指向的文件了。
再查看版本：

```
6.14.4
```

这就是最新版的npm了。
