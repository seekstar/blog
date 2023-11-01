---
title: linux shell 个人学习笔记
date: 2020-02-05 18:10:23
---

安全重启：
按住`alt+<PrtSc>`，然后依次按下reisub即可安全重启。

## 语法

### 条件判断

`man bash`，然后搜索`CONDITIONAL EXPRESSIONS`，可以看到完整的列表。

#### if elif else

参考：<https://blog.csdn.net/u014783674/article/details/24474001>

```shell
#!/bin/bash
if [ condition1 ]; then
	# Do something
elif [ condition2 ]; then
	# Do something
else
	# Do something
fi
```

#### 判断某环境变量是否存在

参考：https://blog.csdn.net/blade2001/article/details/7243143?utm_source=blogxgwz3
~~上面的文章好像写反了~~
例子：判断环境变量DISPLAY是否存在（若不存在说明没有提供显示设备）

```shell
if [ $DISPLAY ]; then
	# DISPLAY存在
else
	# DISPLAY不存在
fi
```

或者

```shell
if [ ! $DISPLAY ]; then
```

表示`如果$DISPLAY不存在`

#### 字符串

| 功能 | 例子 |
| ---- | ---- |
| 为空 | `[ -z "$1" ]` 或者 `[ ! "$1" ]` |
| 非空 | `[ -n "$1" ]` 或者 `[ "$1" ]` |
| 相等 | `[ "$1" == "$2" ]` |
| 不相等 | `[ "$1" != "$2" ]` |

所以如果判断目录是否非空，可以这样：`if [ "$(ls -A xxx)" ]`

参考：<https://www.cyberciti.biz/faq/linux-unix-shell-check-if-directory-empty/>

#### 大小判断

参考：
<https://blog.csdn.net/shang_feng_wei/article/details/90378017>
<https://www.jb51.net/article/56553.htm>
<https://blog.csdn.net/HappyRocking/article/details/90609554#1_70>

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

其中`-eq`和`-ne`可以分别用`=`和`!=`替换。

如果想像C语言那样进行条件判断，可以使用`[[]]`。
例如下面这两句都表示`如果参数的个数等于０或者大于２`

```text
if [[ $# = 0 || $# > 2 ]]; then
```

```text
if [ $# = 0 -o $# -gt 2 ]; then
```

#### 判断文件类型

来源：<https://jingyan.baidu.com/article/95c9d20d5ac536ec4e7561ad.html>

```shell
#!/bin/bash
if [ -z $1 ]; then      #如果没有输入参数，也就是第一个参数的字符串长度为0
    :                          #空语句
else
	if [ -e $1 ]; then       #如果文件存在的话
		if [ -f $1 ]; then   #如果文件是个普通文件？
			echo $1" is a text file."
		elif [ -d $1 ]; then #如果文件是个目录文件？
			echo $1" is a directory."
		elif [ -c $1 ]; then #如果文件是个字符设备？
			echo $1" is a char device."
		elif [ -b $1 ]; then #如果文件是个块设备？
			echo $1" is a block device."
		else #否则
			echo $1" is unknow file."
	fi
fi
```

#### 判断文件权限

| 代码 | 含义 |
| ---- | ---- |
| -r | 存在且可读 |
| -w | 存在且可写 |
| -x | 存在且可执行 |

参考：<https://stackoverflow.com/questions/10319652/check-if-a-file-is-executable>

### 函数

参考：<https://www.runoob.com/linux/linux-shell-func.html>

#### 定义

```shell
function FunctionName {
	do_some_thing_here
	return Interger
}
```

其中`function`可以省略，也可以不return。
参数用法与脚本类似。（`$#`表个数，`$1, $9, ${10}`表具体参数)

#### 使用

```shell
FunctionName par1 par2 par3
```

### 循环

#### while

参考：<https://wiki.jikexueyuan.com/project/shell-tutorial/shell-while-loop.html>

```shell
while Command
do
   Statement(s) to be executed if Command is true
done
```

或者

```shell
while [ Condition ]; do
	Statement(s) to be executed if Condition is true
done
```

也可以对命令返回值取反，比如

```shell
while ! Command; do
	Statement(s) to be executed if Command is false
done
```

#### for

参考：<https://blog.csdn.net/astraylinux/article/details/7016212>

```shell
for ((i=0; i<10; ++i))  
do  
    echo $i  
done  
```

注意是双括号。
还有其他用法。看参考链接

### 正则表达式

```shell
if [[ 字符串 =~ 模式 ]]; then
	echo 字符串中含有模式
fi
```

比如最简单的：

```shell
if [[ 2333test233222 =~ test233 ]]; then
	echo yes;
fi
```

会打印出`yes`。

如果要判断是否不包含：

```shell
if ! [[ 2333test233222 =~ test233 ]]; then
	echo yes;
fi
```

或操作：

```shell
if [[ 2333test233222 =~ abc || 2333test233222 =~ test233 ]]; then
	echo yes;
fi
# yes
```

与操作：

```shell
if [[ 2333test233222 =~ abc && 2333test233222 =~ test233 ]]; then
	echo yes;
fi
```

### 重定向

```shell
# 将`stdout`重定向到`stdout.txt`
Command > stdout.txt
# 将`stderr`重定向到`stderr.txt`
Command 2> stderr.txt
# 将stderr重定向到stdout
Command 2>&1
# 将stderr和stdout都重定向到一个文件
# 参考：<https://blog.csdn.net/u011630575/article/details/52151995>
Command > shell.log 2>&1
Command &> shell.log
# 将`stdin`重定向到`stdin.txt`
Command < stdin.txt
# 将Command1的stdout输入到Command2的stdin
Command1 | Command2 # 例如 echo 'whoami' | bash，可以让bash执行whoami。

```

#### 将多行字面量作为stdin

```text
Command <<标记
第一行
第二行
...
标记
```

例如：

```shell
bash <<EOF
whoami
echo 2333
EOF
```

### 数组

来源：<https://www.yiibai.com/bash/bash-array.html>

#### 定义

```shell
ARRAY_NAME=(element_1st element_2nd element_Nth)
```

#### 访问某个下标的元素

下标从0开始。

```shell
echo ${ARRAY_NAME[2]}
```

#### 访问所有元素

```shell
# 经实测，bash是每个元素一个不带引号的结果，zsh是每个元素一个带引号的结果
echo ${ARRAY_NAME[@]}
echo ${ARRAY_NAME[*]}
# 每个元素一个带引号的结果
echo "${ARRAY_NAME[@]}"
# 所有元素组成一个结果
echo "${ARRAY_NAME[*]}"
```

例如：

```shell
a=(1 "2   3")
# bash 相当于 echo 1 2   3
# zsh 相当于 echo 1 "2   3"
echo ${a[@]}
echo ${a[*]}
# 相当于 echo 1 "2   3"
echo "${a[@]}"
# 相当于 echo "1 2   3"
echo "${a[*]}"
```

#### 访问slice

```shell
# 从第m个开始一直到末尾
${ARRAY_NAME[@]:m}
# 从第m个开始取n个。下标从0开始。
${ARRAY_NAME[@]:m:n}
```

保存为新的数组：

```shell
SLICED_ARRAY=(${ARRAY_NAME[@]:m:n})
```

参考：<https://stackoverflow.com/questions/1335815/how-to-slice-an-array-in-bash>

#### 命令行参数

命令行参数也是数组，用法跟上面的差不多：

```shell
# 访问某参数
echo $2
# 所有参数
echo $@
echo $*
# 从第m个参数开始一直取到末尾
echo ${@:m}
# 从第m个参数开始取n个参数
echo ${@:m:n}
# 参数个数（不含$0）
echo $#
```

当数组被用于命令行参数时，会被展开成一个个参数：

```shell
# 等价于./test.sh 1 2 3
a=(1 2 3)
./test.sh ${a[@]}
```

## 进程

获取当前subshell的PID：

```shell
pid=$(exec sh -c 'echo "$PPID"')
```

来源：<https://unix.stackexchange.com/a/484464>

## 信号

```shell
trap 信号处理命令 信号名
```

例如：

{% post_link Linux/Process/'Linux杀死所有子进程' %}

```shell
# 在脚本退出前杀死所有子进程
trap "pkill -P $$" EXIT
```

## 用户管理

### 创建普通用户

```shell
adduser 用户名
```

但是有些发行版没有`adduser`命令，就只能用`useradd`命令创建用户了：

```shell
# -m: 创建家目录
useradd -m 用户名
# 设置密码
passwd 用户名
```

### 创建系统用户

```shell
# -r, --system: 创建系统用户，UID小于1000，无密码，无家目录，无法登录。
useradd --system 用户名
```

来源：<https://superuser.com/a/515909/1677998>

### 以另一用户的身份执行命令

参考：<https://www.cnblogs.com/bigben0123/archive/2013/05/07/3064843.html>

```shell
sudo -u UserName Command
```

### 判断用户是否存在

```shell
if id "$1" &>/dev/null; then
    echo 'user found'
else
    echo 'user not found'
fi
```

来源：<https://stackoverflow.com/questions/14810684/check-whether-a-user-exists>

### 创建组

```shell
sudo groupadd GroupName
```

### 向组中加入用户

参考：<https://blog.csdn.net/u013078295/article/details/52173311>

```shell
sudo usermod -aG GroupName UserName
```

### 查看group里的用户

参考：<https://blog.csdn.net/withiter/article/details/8132525>里的评论

```shell
grep GroupName /etc/group
```

## `set`

bash可以用`set`来设置一些模式。

### 子命令返回值不为0时退出

`set -e`

但是要注意的是，对于用管道连接起来的几个命令，最终的exit code似乎是管道里的最后一个命令。例如对于`command A | command B`，如果`command A`出错返回非0，但是`command B`正常退出，那么这个组合命令的exit code会被设置成0，这样`set -e`就不会生效。

如果要让被管道组合起来命令中任何一个命令返回非0都会退出，则需要加上`set -o pipefail`，其效果是将exit code赋值为被管道组合起来的命令中最后一个返回非0值的命令。

来源：[Get exit status of process that's piped to another](https://unix.stackexchange.com/a/73180/453838)

## 按应用

### crontab

启动

```shell
service cron start
```

## 按功能

### 查看磁盘占用情况

```shell
df -h
```

### 以默认应用打开文件

```shell
xdg-open FileName
```

### 按照十六进制查看文件

```shell
hexdump -C FileName > hex.out
```

### 查看命令执行时间

```shell
time 命令
```

### 查看8进制文件权限

参考：http://novell.me/Linux/201410/stat-get-file-permission-with-octal-numb.html

```shell
stat -c %a FileName
```

### 监视某命令的执行结果

```shell
watch -n Interval Command
```

Interval: 执行间隔，以秒为单位

### 获取精确到纳秒的当前时间

参考：<https://blog.csdn.net/gengshenghong/article/details/7583580>

```shell
date +%Y%m%d%X%N
```

时间戳

```shell
date +%s%N
```

### 查看端口占用情况

参考：<https://jingyan.baidu.com/article/656db9183861cde381249c87.html>

```shell
lsof -i:8236
```

查看8236端口的占用情况。无输出表示没有被占用。

### 查看发行版信息

参考：<https://blog.csdn.net/sty945/article/details/96475882>

```shell
lsb_release -a
```

我的输出：

```text
No LSB modules are available.
Distributor ID:	Deepin
Description:	Deepin 15.11
Release:	15.11
Codename:	stable
```

### 清空命令历史记录

参考：<https://zhidao.baidu.com/question/1495253179240949419.html>

```shell
history -c
```

### 创建临时文件

```shell
mktemp
```

便会在`/tmp`下创建一个文件并把文件名输出到stdout。
示例：

```shell
echo Please input:
read -s input
tmp=$(mktemp)
echo $input > $tmp
cat $tmp
rm $tmp
```

### 转义

```shell
# hello\\world
printf "%q" "hello\world"
# var='hello\\world'
printf -v var "%q\n" "hello\world"
```

来源：<https://stackoverflow.com/a/2856010/13688160>

### 使用ImageMagick将多个jpg转换为A4大小的PDF

转自：<https://blog.csdn.net/lpwmm/article/details/83503736>

```shell
convert a.png b.png -compress jpeg -resize 1240x1753 \
				  -extent 1240x1753 -gravity center \
				  -units PixelsPerInch -density 150x150 multipage.pdf
```

如果不想限定高度，可以

```shell
convert a.png b.png -compress jpeg -resize 1240 \
				  -extent 1240 -gravity center \
				  -units PixelsPerInch -density 150x150 multipage.pdf
```

### 生成随机数

```shell
echo $RANDOM
```

生成长度为n字节的16进制随机数（最终生成的16进制字符串的长度是2n）：

```shell
openssl rand -hex n
```

来源：[Linux Shell产生16进制随机数](https://blog.csdn.net/weixin_30325071/article/details/94910182)

### 提取文件后缀名

```shell
filename=test.tar.gz
# gz
echo ${filename##*.}
# tar.gz
echo ${filename#*.}
```

来源：<https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash>

### 带单位容量转字节数

```shell
pip3 install humanfriendly
# 2000
humanfriendly --parse-size="2 KB"
# 2048
humanfriendly --parse-size="2 KiB"
```

来源：<https://stackoverflow.com/a/46373468>

### 读取JSON

用`jq`

```shell
# Debian
sudo apt install jq
# ArchLinux
sudo pacman -S jq
```

```shell
curl -s 'https://api.github.com/users/lambda' | jq -r '.name'
```

```text
Brian Campbell
```

如果field不一定存在，可以用这个方式判断：

```shell
name=$(curl -s 'https://api.github.com/users/lambda' | jq -er '.name')
if [ $? -eq 0 ]; then
	echo $name
else
	echo name does not exist
fi

name1=$(curl -s 'https://api.github.com/users/lambda' | jq -er '.name1')
if [ $? -eq 0 ]; then
	echo $name1
else
	echo name1 does not exist
fi
```

```text
Brian Campbell
name1 does not exist
```

```text
○   -e / --exit-status:

	Sets  the  exit status of jq to 0 if the last output values was neither false nor null, 1 if the last output value was either false or null, or 4 if no valid result was ever produced.
```

参考：<https://stackoverflow.com/a/53135202/13688160>

## 按命令

### awk

[Linux awk 命令](https://m.runoob.com/linux/linux-comm-awk.html)

[AWK 条件语句与循环](https://www.runoob.com/w3cnote/awk-if-loop.html)

#### 求和

```shell
seq 1 10 | awk '{s+=$1} END {print s}'
```

来源：<https://stackoverflow.com/questions/450799/shell-command-to-sum-integers-one-per-line>

### comm

求两个有序文件中的相同行和不同行。第一列是只在第一个文件中的行，第二列是只在第二个文件中的行，第三列是两个文件都存在的行。常用命令行选项：

- `-1`: 不输出第一列
- `-2`: 不输出第二列
- `-3`: 不输出第三列

参考：<https://unix.stackexchange.com/questions/28865/list-the-difference-and-overlap-between-two-plain-data-set>

### diff

忽略换行符的区别：`--strip-trailing-cr`

来源：<https://stackoverflow.com/questions/40974170/how-can-i-ignore-line-endings-when-comparing-files>

### dpkg

```shell
dpkg --list
```

显示当前已经安装的软件

### du

`-d数字`: 目录层数。0表示当前目录，1表示当前目录下的所有文件和子目录，以此类推。

`--all`: 显示文件大小。默认只显示目录大小。

- 查看当前目录下所有文件夹的大小

```shell
du -h
```

`-h`是`--human-readable`的缩写。

- 查看当前目录的大小

```shell
du -sh
```

`-s`是`--summarize`的缩写。

- 按大小排序

```shell
du -hd 1 --all 目录 | sort -h
```

来源：<https://serverfault.com/questions/62411/how-can-i-sort-du-h-output-by-size>

参考：<https://jingyan.baidu.com/article/ca2d939d7867e0eb6c31ce80.html>

### find

```text
find [目录] [查找规则] [查找完后执行的action]
查找规则：
-name 根据文件名查找（精确查找）
-iname 不区分大小写
```

例子

- 在当前目录下找到所有名字为input.txt的文件并将其放入回收站

```shell
find . -name "input.txt" -exec trash-put {} \;
```

其中{}替代查找到的文件，”\;”是-exec的结束符

- 在当前目录下不区分大小写地找以Edition.pdf结尾的文件

```shell
find -iname *Edition.pdf
```

- 在根目录下查找名字为gsettings的文件或文件夹，但是忽略目录/mnt和/media

这些都不对，不知道为什么

```shell
sudo find / -name “gsettings” ! -path “/mnt/*” ! -path “/media/*”
sudo find / -path /media -path /mnt -prune -o -name gsettings
sudo find . -name media -name mnt -prune -o -name gsettings
sudo find . -path ./media -path ./mnt -prune -o -name gsettings
sudo find . -name b ! -path “./a/*”
```

### grep

- 查找当前目录下有某字符串的文件：

```shell
grep -rn string *
```

-r:递归查找
-n:显示行号
-i:忽略大小写
*:当前目录所有文件。可以换成某个文件名。

- 查找当前目录下后缀名为`.rs`的文件中含有`splay_safe_rs`的文件：

```shell
grep -rn splay_safe_rs --include \*.rs
```

来源：<https://stackoverflow.com/questions/12516937/how-can-i-grep-recursively-but-only-in-files-with-certain-extensions>

### ip

查看本机ip地址

```shell
ip addr
```

### join

<https://www.geeksforgeeks.org/join-command-linux/>

### less

最基础用法：

```shell
less 文件路径
```

显示行号：

```shell
less -N 文件路径
```

也可以在`less`里面按`-` `N` `Enter`即可显示/隐藏行号。

跳转到指定行：在`less`里面输入自己要跳转的行号，然后按`g`

来源：[Linux之Less命令跳转到特定的行号](https://blog.csdn.net/lovedingd/article/details/120885183)

### locate

```shell
locate name
```

查找文件（文件夹）

### ls

列出目录中的文件和文件夹。常用命令行选项：

- `-a`: 列出所有项。默认会隐藏`.`开头的项。
- `-l`: 列出详细信息。
- `-t`: 根据时间倒序排序。

详见：<https://blog.csdn.net/nb1253587023/article/details/127188039>

### pidof 进程名

返回某进程名对应的pid
例子：
杀掉所有名字为ssh-agent的进程

```shell
kill $(pidof ssh-agent)
```

### sed

从stdin读入，将修改后的结果写入到stdout：

```shell
sed '命令'
```

其中`命令`形如`s/源pattern/目的pattern/g`（全局替换）

从文件读入，将修改后的结果写入到stdout：

```shell
sed '命令' FileName
```

### top

`-H`: 显示单个线程。<https://serverfault.com/questions/38195/getting-a-per-thread-cpu-stats>

#### 基础知识

[sed模式空间(pattern space)和保持空间(hold space)](https://blog.csdn.net/demon7552003/article/details/72854231)

<https://stackoverflow.com/questions/12833714/the-concept-of-hold-space-and-pattern-space-in-sed>

sed读取一行时，会先将其暂存到模式空间。处理完一行之后就会把模式空间中的内容打印到标准输出，然后自动清空缓存。

保持空间是sed中的另外一个缓冲区，此缓冲区正如其名，不会自动清空，但也不会主动把此缓冲区中的内容打印到标准输出中。

d: 删除模式空间的内容，开始下一个循环

g: 复制保持空间的内容到模式空间

`s/regexp/replacement/`: 在模式空间中如果匹配到了正则表达式`regexp`，就将其替换为`replacement`

{% post_link Other/Language/正则表达式学习笔记 %}

需要注意的是，`sed`的正则表达式中，如果用到了`(`, `)`, `|`，需要在前面放一个`\`将它们转义，例如`sed '/\(patternx\|patterny\)/p'`。来源：<https://stackoverflow.com/questions/14813145/boolean-or-in-sed-regex>

#### 全局替换

`sed 's/regexp/replacement/g'`

其中`s`是替换命令，表示在模式空间尝试匹配正则表达式`regexp`，找到了就将其替换为`replacement`。

这里的`g`不是命令，而是隶属于`s`命令的一个flag，表示全局替换，也就是说在匹配到一个之后不停下来，而是马上继续尝试匹配下一个。

一些例子：

- 把文件中的CRLF替换成LF

`sed 's/\r//g`

`\r`就是CR，将其替换成空就相当于把它删了。

- 把文件中的LF替换成CRLF

`sed 's/$/\r/g`

`$`的意思是每行的末尾。在每行的末尾把空字符串替换成`\r`（CR），也就是插入`\r`（CR）。在linux中换行是LF，所以相当于在LF前面插入一个CR，变成CRLF。

- 保留每行的最后一个单词

`sed 's/.* //g`

正则表达式里，点`.`几乎可以匹配任何字符，所以`.*`会尽量匹配尽量长的字符串。`/.* /`表示最长的以空格结尾的字符串。目的pattern为空，这样就相当于把每行的最长的以空格结尾的字符串删掉。所以每行只留下了最后一个单词了。

- 在每个单词前插入

参考：<https://blog.csdn.net/lwlfox/article/details/85065026>

`sed 's/\b\S*\b/test&/g`

`\b`: 单词边界
`&`: 前面匹配的字符串

- 保留部分内容的替换

有点像`scanf`和`printf`的组合：

<https://blog.csdn.net/scl323/article/details/84098366>

#### 删除匹配行

`sed '/regexp/d'`

如果模式空间有可以匹配正则表达式`regexp`的子串，那么就将模式空间删除，然后继续读取下一行到模式空间。

#### 常用选项

`-i`: 直接修改文件（默认是输出编辑后的结果到stdout）。

`--follow-symlinks`: `-i`会破坏符号链接和硬链接，加上这个选项之后可以保护软链接不被破坏，但是不保护硬链接。参考：<https://www.cnblogs.com/cherryhaha1234/p/10848024.html>

`-c`: 保护符号链接和硬链接（但是我的sed没有这个选项）。

`-n`: sed默认会将文件的每行打印出来，然后对匹配的内容进行相应的操作。`-n`表示不把文件的每行都打印出来，只对匹配的内容做相应的操作。

匹配指定行：`sed -n 起始行号[,终止行号]动作 file`，动作一般是`p`，即打印(Print)。



例子：

打印第2行：`sed -n '2p' file`

打印第2行到第4行：`sed -n '2,4p' file`

参考：<https://www.commandlinefu.com/commands/view/3802/to-print-a-specific-line-from-a-file>

### sort

`-k列号`: 按这一列排序。列号从1开始。

`-r`: 逆序

`-n`: `--numeric-sort`。按照数字排序。默认是按照字符串排序。

`-o 文件`: 输出到文件。默认是输出到stdout的。

#### 排序

参考：<https://stackoverflow.com/a/17048248>

#### 去重

参考网站：<https://www.cnblogs.com/rwxwsblog/p/4564216.html>

例如txt中有

```text
jason
jason
jason
fffff
jason
```

执行以下命令

```shell
sort -u txt
```

输出

```text
fffff
jason
```

输出到文件

```shell
sort -u txt -o txt1
```

## 其他

{ post_link shell/'zsh使用笔记' }

[linux中怎么用shell显示文件某一行或几行内容](https://blog.csdn.net/mydriverc2/article/details/82623778)

[linux shell 将多行文件转换为一行](https://blog.csdn.net/hjxhjh/article/details/17264739)

`[`和`[[`的区别：<https://stackoverflow.com/questions/3427872/whats-the-difference-between-and-in-bash>
