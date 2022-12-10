---
title: ArchLinux安装NVIDIA驱动
date: 2022-12-10 11:40:41
tags:
---

官方完整教程：<https://wiki.archlinux.org/title/NVIDIA>

只要卡不是太老，一般情况下，如果用的是stable内核(`linux`)，就安装`nvidia`，如果用的是LTS内核(`linux-lts`)，就安装`nvidia-lts`。包里自带了把`nouveau`屏蔽掉的配置文件，因此重启即可。

然后执行`nvidia-smi`，有这种输出就说明安装成功了：

```text
Sat Dec 10 11:54:20 2022       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 525.60.11    Driver Version: 525.60.11    CUDA Version: 12.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0 Off |                  N/A |
| N/A   74C    P0    50W /  N/A |     67MiB /  4096MiB |     94%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A       950      G   /usr/lib/Xorg                       4MiB |
|    0   N/A  N/A     18194      C   ...psieveCUDA_0.2.3b_linux64       58MiB |
+-----------------------------------------------------------------------------+
```

有些应用依赖`opencl`，一款编程框架，类似于CUDA，因此也建议安装`opencl-nvidia`，这样使用opencl的程序就可以调用NVIDIA GPU的算力了。
