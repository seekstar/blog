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

## 组管理

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

### 去重

参考网站：https://www.cnblogs.com/rwxwsblog/p/4564216.html
例如txt中有

```
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

### 把stderr和stdout都重定向到一个文件

参考：<https://blog.csdn.net/u011630575/article/details/52151995>

```shell
./shell.sh > shell.log 2>&1
```

### 以另一用户的身份执行命令

参考：<https://www.cnblogs.com/bigben0123/archive/2013/05/07/3064843.html>

```shell
sudo -u UserName Command
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

```
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

## 按命令

### du

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

参考：<https://jingyan.baidu.com/article/ca2d939d7867e0eb6c31ce80.html>

### pidof 进程名

返回某进程名对应的pid
例子：
杀掉所有名字为ssh-agent的进程

```shell
kill $(pidof ssh-agent)
```

### ip

查看本机ip地址

```shell
ip addr
```

### dpkg

```shell
dpkg --list
```

显示当前已经安装的软件

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

### find

```
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

### locate

```shell
locate name
```

查找文件（文件夹）

### sed

#### 模式匹配

从stdin读入，将修改后的结果写入到stdout：

```shell
sed 's/源pattern/目的pattern/g'
```

其中`s`是指替换，`g`是全局替换，`/`是分隔符。然后sed就会逐行去找源pattern，并且替换为目的pattern。

从文件读入，将修改后的结果写入到stdout：

```shell
sed 's/源pattern/目的pattern/g' FileName
```

源pattern和目的pattern的一些例子见：{% post_link Other/Language/正则表达式学习笔记 %}

此外，sed提供了一些选项：

`-i`: 直接修改文件（默认是输出编辑后的结果到stdout）。

`--follow-symlinks`: `-i`会破坏符号链接和硬链接，加上这个选项之后可以保护软链接不被破坏，但是不保护硬链接。参考：<https://www.cnblogs.com/cherryhaha1234/p/10848024.html>

`-c`: 保护符号链接和硬链接（但是我的sed没有这个选项）。

#### 匹配指定行

`sed -n 起始行号[,终止行号]动作 file`

动作一般是`p`，即打印(Print)。

sed默认会将文件的每行打印出来，然后对匹配的内容进行相应的操作。`-n`表示不把文件的每行都打印出来，只对匹配的内容做相应的操作。

例子：

打印第2行：`sed -n '2p' file`

打印第2行到第4行：`sed -n '2,4p' file`

参考：<https://www.commandlinefu.com/commands/view/3802/to-print-a-specific-line-from-a-file>

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

### diff

忽略换行符的区别：`--strip-trailing-cr`

来源：<https://stackoverflow.com/questions/40974170/how-can-i-ignore-line-endings-when-comparing-files>

### zsh不共享历史

`zsh`特性比bash丰富一些。zsh默认会在不同的会话之间共享历史，禁用这个特性：

```shell
# https://github.com/ohmyzsh/ohmyzsh/issues/2537
echo "unsetopt share_history" >> ~/.zshrc
```

## 其他

[linux中怎么用shell显示文件某一行或几行内容](https://blog.csdn.net/mydriverc2/article/details/82623778)

[linux shell 将多行文件转换为一行](https://blog.csdn.net/hjxhjh/article/details/17264739)

[Linux awk 命令](https://m.runoob.com/linux/linux-comm-awk.html)

[AWK 条件语句与循环](https://www.runoob.com/w3cnote/awk-if-loop.html)

`[`和`[[`的区别：<https://stackoverflow.com/questions/3427872/whats-the-difference-between-and-in-bash>
