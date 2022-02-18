---
title: Linux多线程复制目录
date: 2021-07-21 13:13:08
---

比如有一个目录a需要复制：

```shell
mkdir a
touch a/a
mkdir a/b
touch a/b/c
tree a
```

```text
a
├── a
└── b
    └── c
```

将其复制为目录`d`只需要用find找出目录下所有的文件，然后用gnu-parallel开多线程逐个复制即可：

```shell
mkdir d
cd a
find . -type f | parallel -j4 cp --parents {} ../d
tree ../d
```

```text
../d
├── a
└── b
    └── c
```

`-type f`: 只打印文件，不打印目录
`-j4`: 最多并行跑4个任务。这个并行数可以改成其他值，改成0表示越多越好（一个CPU核心跑一个任务）。
`--parents`: 路径也一起复制

或者用xargs

```shell
find . -type f | xargs -P 4 -I {} cp --parents {} ../d
```

`-P`: `--max-procs`
