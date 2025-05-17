---
title: POSIX shell学习笔记
date: 2024-07-29 13:39:27
tags:
---

学习POSIX shell建议使用dash，因为它很快：<https://unix.stackexchange.com/a/148098>

`man dash`: Only features designated by POSIX, plus a few Berkeley extensions, are being incorporated into this shell.

## 条件判断

`man dash`，然后搜索`test expression`，可以看到完整的列表。

### if elif else

```sh
#!/usr/bin/env sh
if [ condition1 ]; then
	# Do something
elif [ condition2 ]; then
	# Do something
else
	# Do something
fi
```

### 判断某环境变量是否存在

参考：<https://blog.csdn.net/blade2001/article/details/7243143?utm_source=blogxgwz3>

上面的文章好像写反了

例子：判断环境变量DISPLAY是否存在（若不存在说明没有提供显示设备）

```sh
if [ "$DISPLAY" ]; then
	# DISPLAY存在
else
	# DISPLAY不存在
fi
```

或者

```sh
if [ ! "$DISPLAY" ]; then
	# DISPLAY不存在
```

### 字符串

| 功能 | 例子 |
| ---- | ---- |
| 为空 | `[ -z "$1" ]` 或者 `[ ! "$1" ]` |
| 非空 | `[ -n "$1" ]` 或者 `[ "$1" ]` |
| 相等 | `[ "$1" = "$2" ]` |
| 不相等 | `[ "$1" != "$2" ]` |
| 字典序小于 | `[ "$1" \< "$2" ]` |
| 字典序大于 | `[ "$1" \> "$2" ]` |

所以如果判断目录是否非空，可以这样：`if [ "$(ls -A xxx)" ]`

参考：<https://www.cyberciti.biz/faq/linux-unix-shell-check-if-directory-empty/>

### 整数的大小判断

| 代码 | 含义 | 例子 |
| ---- | ---- | ---- |
| -eq | = | `[ $1 -eq 2 ]` |
| -ne | != | `[ $1 -ne 2 ]` |
| -le | <= | `[ $1 -le 2 ]` |
| -lt | < | `[ $1 -lt 2 ]` |
| -ge | >= | `[ $1 -ge 2 ]` |
| -gt | > | `[ $1 -gt 2 ]` |
| -a | && | `[ $1 -gt 0 -a $1 -lt 10 ]` |
| -o | \|\| | `[ $1 -lt 0 -o $1 -gt 10 ]` |

### 浮点数的大小判断

```sh
if awk "BEGIN {exit !(1.234 >= .233)}"; then
    echo "yes"
fi
```

来源：<https://stackoverflow.com/a/45591665/13688160>

### 判断文件类型

来源：<https://jingyan.baidu.com/article/95c9d20d5ac536ec4e7561ad.html>

```sh
#!/usr/bin/env sh
if [ -z "$1" ]; then      #如果没有输入参数，也就是第一个参数的字符串长度为0
    :                          #空语句
else
	if [ -e "$1" ]; then       #如果文件存在的话
		if [ -f "$1" ]; then   #如果文件是个普通文件？
			echo "$1 is a text file."
		elif [ -d "$1" ]; then #如果文件是个目录文件？
			echo "$1 is a directory."
		elif [ -c "$1" ]; then #如果文件是个字符设备？
			echo "$1 is a char device."
		elif [ -b "$1" ]; then #如果文件是个块设备？
			echo "$1 is a block device."
		else #否则
			echo "$1 is unknow file."
	fi
fi
```

另外，`-s`表示文件存在且不为空。来源：<https://stackoverflow.com/questions/9964823/how-to-check-if-a-file-is-empty-in-bash>

### 判断文件权限

| 代码 | 含义 |
| ---- | ---- |
| -r | 存在且可读 |
| -w | 存在且可写 |
| -x | 存在且可执行 |

参考：<https://stackoverflow.com/questions/10319652/check-if-a-file-is-executable>

## 函数

参考：<https://www.runoob.com/linux/linux-shell-func.html>

### 定义

如果想要修改全局变量的话：

```sh
a=1
FunctionName() { # 这里是花括号
	a=233 # 修改了全局变量
	do_some_thing_here
	return Interger
}
```

如果不想修改全局变量的话，就让整个函数在一个subshell里：

```sh
# https://stackoverflow.com/a/18600920/13688160
a=1
FunctionName() ( # 这里是圆括号
	a=233 # 修改的是全局变量在本地的拷贝，全局变量的值保持不变
	do_some_thing_here
	return Interger
)
```

也可以不return。

参数用法与脚本类似。`$#`表个数，`$1, $9, ${10}`表具体参数。

### 使用

```sh
FunctionName par1 par2 par3
```

## 循环

### while

参考：<https://wiki.jikexueyuan.com/project/shell-tutorial/shell-while-loop.html>

```sh
while Command
do
   Statement(s) to be executed if Command is true
done
```

或者

```sh
while [ Condition ]; do
	Statement(s) to be executed if Condition is true
done
```

也可以对命令返回值取反，比如

```sh
while ! Command; do
	Statement(s) to be executed if Command is false
done
```

## 重定向

```sh
# 将`stdout`重定向到`stdout.txt`
Command > stdout.txt
# 将`stderr`重定向到`stderr.txt`
Command 2> stderr.txt
# 将stderr重定向到stdout
Command 2>&1
# 将stderr和stdout都重定向到一个文件
# 参考：<https://blog.csdn.net/u011630575/article/details/52151995>
Command > shell.log 2>&1
# 将`stdin`重定向到`stdin.txt`
Command < stdin.txt
# 将Command1的stdout输入到Command2的stdin
Command1 | Command2 # 例如 echo 'whoami' | sh，可以让sh执行whoami。
```

## 将多行字面量作为stdin

```text
Command <<标记
第一行
第二行
...
标记
```

例如：

```sh
sh <<EOF
whoami
echo 2333
EOF
```

## 命令行参数

```shell
arg_num() {
	# 参数个数（不含$0）
	echo $#
}
# 访问某参数
echo "$2"
# 相当于arg_num "$1" "$2"
arg_num "$@"
# 相当于arg_num "$1 $2"
arg_num "$*"
```

```text
shift [n]
	Shift  the  positional  parameters  n  times.  A shift sets the value of $1 to the value of $2, the value of $2 to the
	value of $3, and so on, decreasing the value of $# by one.  If n is greater than the number of positional  parameters,
	shift will issue an error message, and exit with return status 2.
```

`n`似乎默认是1。

## 把变量展开成多个参数

如果确保参数中没有空格，可以这样：

```shell
arg_num() {
	# 参数个数（不含$0）
	echo $#
}
args="a b"
# 相当于arg_num a b
arg_num $args
```

注意，引号会被原样传递：

```shell
args="\"a  b\""
# 相当于arg_num '"a' 'b"'
arg_num $args
```

所以如果某个参数中有空格，那么不能用上面的方式，而是要这样：

```shell
args="\"a  b\"  \"c  d\""
eval "set -- $args"
# eval会执行set -- "a  b"  "c  d"，将$1设置成"a  b"，将$2设置成"c  d"
# 相当于arg_num "$1" "$2", 即arg_num "a  b" "c  d"
arg_num "$@"
```

```text
       set [{ -options | +options | -- }] arg ...
              To change the  positional  parame‐
              ters  without  changing  any options, use “--” as the first argument to set.
              If no args are present, the set command will clear all the positional  para‐
              meters (equivalent to executing “shift $#”.)
```

## Command substitution

把命令的输出会保存到变量：

```sh
a=$(command args...)
```

但如果是要把输出当字符串用，需要在周围加上双引号。但是要注意，`$(`和`)`之间的内容不需要再加一层转义。举个例子，判断当前目录是不是`a b`：

```shell
check() {
	# 而不是 "$(basename \"$(pwd)\")"
	if [ "$(basename "$(pwd)")" = "a b" ]; then
		echo yes
	else
		echo no
	fi
}
check
mkdir -p "a b"
cd "a b"
check
```

其中`"$(basename "$(pwd)")"`相当于先执行`basename "$(pwd)"`，再把输出用双引号包起来变成字符串。

如果改成`"$(basename \"$(pwd)\")"`，就变成执行`basename \"$(pwd)\"`，也就是先执行`pwd`，然后执行`basename \"a b\"`，结果就变成`a`了。

相关文档：<https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html>

## 进程

获取当前subshell的PID：

```shell
pid=$(exec sh -c 'echo "$PPID"')
```

来源：<https://unix.stackexchange.com/a/484464>

## `set`

可以用`set`来设置一些模式。

### 子命令返回值不为0时退出

`set -e`

相当于在每条命令后面加上了`|| exit $?`

但是要注意的是，对于用管道连接起来的几个命令，最终的exit code似乎是管道里的最后一个命令。例如对于`command A | command B`，如果`command A`出错返回非0，但是`command B`正常退出，那么这个组合命令的exit code会被设置成0，这样`set -e`就不会生效。

bash支持`set -o pipefail`，其效果是将exit code赋值为被管道组合起来的命令中最后一个返回非0值的命令，这样被管道组合起来命令中任何一个命令返回非0都会退出。

来源：[Get exit status of process that's piped to another](https://unix.stackexchange.com/a/73180/453838)

## `trap`

格式：

```shell
trap 命令 事件
```

常用事件：

- `EXIT`: `exit`被调用

常用信号：
- `HUP`: SIGHUP，父进程退出的时候会向子进程发送SIGHUP。但注意，如果父进程是被`SIGKILL`杀死的，那SIGHUP不一定会发送到子进程。
- `INT`: SIGINT，可以由ctrl+c触发
- `TERM`: SIGTERM

例子：

```shell
# a.sh
trap 'exit 1' INT
trap 'echo cleanup' EXIT
sleep 3
```

`sh a.sh`，然后`ctrl+c`，`INT`事件被触发，从而调用`exit 1`，进而触发`EXIT`事件，从而调用`echo cleanup`，然后屏幕上会打印一行`cleanup`。

来源：<https://newbe.dev/exit-trap-in-dash-vs-ksh-and-bash>

但是要注意的是，如果脚本正在执行一个外部命令，比如`sleep`，这时脚本里的`trap`是不会被调用的。因此在需要进行信号处理的脚本中如果需要执行时间很长的命令，那么要把这个命令放到子进程里跑，然后在主进程里wait。例如`test.sh`：

```sh
#!/usr/bin/env sh
trap 'echo exit 1; exit 1' TERM
sleep 1000000
```

```sh
./test.sh &
pid=$!
sleep 1
kill -TERM $pid
```

这时候这个进程是杀不死的，因为`sleep 1000000`阻塞了脚本，所以`trap`没有执行。但我们可以把`sleep`放到子进程里：

```sh
#!/usr/bin/env sh
sleep 100000 &
pid=$!
trap "kill -TERM $pid; echo exit 1; exit 1" TERM
wait
```

再执行上面的命令，这个脚本就可以被顺利杀死了。

如果是pipeline命令，直接将其放入后台的话，`$!`只是pipeline里的最后进程，将其杀掉只会导致pipeline前面的进程变成孤儿进程。为了一次性将整个pipeline杀死，可以用`setsid`将其放入一个单独的进程组里，然后向整个进程组发信号：

```sh
#!/usr/bin/env sh
setsid sh -c "sleep 10 | sleep 10" &
trap "kill -TERM -$!; echo exit 1; exit 1" TERM
wait
```

详情请参考：{% post_link Linux/Process/'Linux-shell向进程组发信号' %}

## `wait`

如果不带参数，就是等待所有后台任务完成。

也可以等待一个特定进程：`wait <PID>`

bash中可以`wait -n`来等待任意一个后台任务完成，但POSIX标准中没有这个。

在POSIX shell中如果要等待多个任务中的任意一个完成，然后把其他的杀掉，可以这样：

```sh
#!/usr/bin/env sh
# "wait -n" is not available in POSIX
trap "exit 1" CHLD
trap "pkill -P $$; exit 1" EXIT
sleep 10 &
sleep 3 &
wait
```

其中`$$`是当前shell的PID，`pkill -P $$`表示把父进程是当前shell的所有进程杀掉。

来源：<https://unix.stackexchange.com/a/231678>

如果是带pipeline的复杂命令，需要这样：

```sh
#!/usr/bin/env sh
# "wait -n" is not available in POSIX
trap "exit 1" CHLD
trap "pkill -P $$; exit 1" EXIT
(
    setsid sh -c "sleep 10 | sleep 10" &
    trap "kill -TERM -$!" TERM
    wait
) &
sleep 3 &
wait
```

但是需要注意的是，`$$`在subshell中会被展开为shell的PID，而不是subshell的PID。因此如果在subshell中，需要这样：

```sh
#!/usr/bin/env sh
(
	# https://unix.stackexchange.com/a/484464
	pid=$(exec sh -c 'echo "$PPID"')
	# "wait -n" is not available in POSIX
	trap "exit 1" CHLD
	trap "pkill -P $pid; exit 1" EXIT
	(
		setsid sh -c "sleep 10 | sleep 10" &
		trap "kill -TERM -$!" TERM
		wait
	) &
	sleep 3 &
	wait
)
```

{% spoiler （不推荐）把它们都放进一个process group里，最后一起杀掉 %}

```sh
#!/usr/bin/env sh
setsid sh -c "
	sleep 10 &
	sleep 3 &
	trap \"kill -TERM -\$\$\" CHLD
	wait
"
```

但是这个方法因为会把自己杀掉，所以会打印一行`Terminated`。

{% endspoiler %}

## `case`

```shell
case 表达式 in
	正则1)
		命令...
		;;
	正则2)
		命令...
		;;
	正则3|正则4)
		命令...
		;;
	*)
		默认命令...
		;;
esac
```

## Conditional substitution

```shell
${VAR:+内容}
```

如果VAR存在，它就会展开成`内容`，如果VAR不存在，就展开成空的。

跟case配合可以实现往`PATH`里添加路径：

```shell
append_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}
```

如果`PATH`不存在，`${PATH:+$PATH:}$1`就展开为`$1`，如果`PATH`存在，就展开为`$PATH:$1`。

同理，也可以往`PATH`的前面添加路径：

```shell
prepend_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="$1${PATH:+:$PATH}"
    esac
}
```

## unset

文档：<https://pubs.opengroup.org/onlinepubs/009696699/utilities/unset.html>

默认是`unset`环境变量。但如果是要unset函数，要用`unset -f`。

## 存在的问题

- 不支持数组

- 不支持`wait -n`
