---
title: 解决wsl配色难看的问题
date: 2020-03-26 20:02:14
---

思路：用vscode连接wsl，然后用vscode的终端操作wsl即可。

首先在vscode的拓展库中搜索wsl，然后安装`Remote  - WSL`拓展。
然后在左下角多了一个打开远程窗口的按钮
![在这里插入图片描述](解决wsl配色难看的问题/20200326195657106.png)
如果没有，重启vscode试试。

然后点击这个按钮，就会打开一个新的vscode窗口，一般会自动连接wsl。然后会下载依赖（下载得很慢）。下载完就会自动连上wsl。打开终端，把终端最大化，就可以当wsl终端用了。
