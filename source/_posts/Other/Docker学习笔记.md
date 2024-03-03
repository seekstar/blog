---
title: Docker学习笔记
date: 2024-03-03 19:26:28
tags:
---

## 安装

不要安装debian自带的docker：`sudo apt install docker-compose`。debian 11和debian 12安装的都是v1，没有docker compose命令。

用官网的安装方式：<https://docs.docker.com/engine/install/debian/#install-using-the-repository>

## 创建image

<https://docs.docker.com/reference/cli/docker/image/build/>

image就是文件系统镜像。

```shell
docker build -t <image-name> [-f <Dockerfile-path>] <context-path>
```

## 列出image

```shell
docker images
```

## 删除image

```shell
docker image rm [OPTIONS] IMAGE [IMAGE...]
```

## 创建container

<https://docs.docker.com/reference/cli/docker/container/run/>

container基于image创建，相当于一个vm

```shell
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

常用选项：

`--name`: Assign a name to the container
`-i, --interactive`:	Keep STDIN open even if not attached
`-t, --tty`: Allocate a pseudo-TTY

如果需要一个shell：

```shell
docker run -it <image> /bin/bash
```

## 启动container

<https://docs.docker.com/reference/cli/docker/container/start/>

```shell
docker container start [OPTIONS] CONTAINER [CONTAINER...]
```

## 列出container

列出running container:

```shell
docker container ls
```

列出所有container:

```shell
docker container ls -a
```

## 复制文件到container

<https://docs.docker.com/reference/cli/docker/container/cp/>

```shell
docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH
docker cp [OPTIONS] SRC_PATH CONTAINER:DEST_PATH
```

## 在running container中运行命令

```shell
docker exec -it <container-ID> /bin/bash
```

## 删除container

<https://docs.docker.com/reference/cli/docker/container/rm/>

```shell
docker rm <container-name>
```

## 查看正在运行的container

```shell
docker ps
```

## volume

<https://docs.docker.com/storage/volumes/>

一个volume是host上的一个文件夹。容器将volume挂载到它自己的文件系统上时，相当于把volume对应的文件夹挂载到它自己的文件系统上。

## 列出所有volume

```shell
docker volume ls
```

## 查看volume详细信息

<https://docs.docker.com/reference/cli/docker/volume/inspect/>

```shell
docker volume inspect [OPTIONS] VOLUME [VOLUME...]
```

好像看不到什么有用的信息。

## 删除volume

<https://docs.docker.com/reference/cli/docker/volume/rm/>

```shell
docker volume rm [OPTIONS] VOLUME [VOLUME...]
```

## 清理cache

<https://docs.docker.com/reference/cli/docker/builder/prune/>

```shell
docker builder prune
```

## `docker system prune -a`

不删volume和手动创建的image。
