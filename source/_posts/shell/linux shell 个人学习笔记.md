---
title: linux shell 个人学习笔记
date: 2020-02-05 18:10:23
---

安全重启：
按住`alt+<PrtSc>`，然后依次按下reisub即可安全重启。

## 语法

bash支持所有POSIX shell的语法：{% post_link shell/'POSIX-shell学习笔记' %}

下面的是不在POSIX标准里的特性。

### 条件判断

`man bash`，然后搜索`CONDITIONAL EXPRESSIONS`，可以看到完整的列表。

### for

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
# 等价于 Command > shell.log 2>&1
Command &> shell.log
```

### 数组

来源：<https://www.yiibai.com/bash/bash-array.html>

#### 定义

```shell
ARRAY_NAME=(element_1st element_2nd element_Nth)
```

#### 新增元素

```shell
a=(1 2 3)
a+=(4 5)
echo "${a[@]}"
```

```text
1 2 3 4 5
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
arg_num() {
	echo $#
}
a=(1 "2   3")
# bash 相当于 arg_num 1 2   3
# zsh 相当于 arg_num 1 "2   3"
arg_num ${a[@]}
arg_num ${a[*]}
# 相当于 arg_num 1 "2   3"
arg_num "${a[@]}"
# 相当于 arg_num "1 2   3"
arg_num "${a[*]}"
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

#### 长度

```shell
a=(1 2 3 4)
echo ${#a[@]}
```

来源：<https://stackoverflow.com/a/1886483/13688160>

#### 命令行参数

当数组被用于命令行参数时，会被展开成一个个参数：

```shell
# 等价于./test.sh 1 2 3
a=(1 2 3)
./test.sh ${a[@]}
```

```shell
# 从第m个参数开始一直取到末尾
echo ${@:m}
# 从第m个参数开始取n个参数
echo ${@:m:n}
```

#### 生成序列

```shell
a=($(seq 1 4))
echo "${a[@]}"
```

```text
1 2 3 4
```

参考：<https://stackoverflow.com/questions/39267836/create-an-array-with-a-sequence-of-numbers-in-bash>

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

### 时间戳转时间字符串

```shell
date -d '@2147483647'
```

### 时间字符串转时间戳

```shell
# +%Y/%m/%d %H:%m:%S
date -d '2025/07/28 00:34:07' +%s
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
if name=$(curl -s 'https://api.github.com/users/lambda' | jq -er '.name'); then
	echo $name
else
	echo name does not exist
fi

if name1=$(curl -s 'https://api.github.com/users/lambda' | jq -er '.name1'); then
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

如果是读取带有特殊字符的域，加上引号即可：

```shell
db_size=$(jq -r ".\"db-size\"" < stats.json)
```

## 按命令

### awk

[Linux awk 命令](https://www.runoob.com/linux/linux-comm-awk.html)

[AWK 条件语句与循环](https://www.runoob.com/w3cnote/awk-if-loop.html)

坑点：如果变量不存在，awk不会报错，而是会把这个变量解析成0：<https://stackoverflow.com/questions/49447987/testing-a-non-existent-variable-in-awk>

#### 内置函数

完整列表：<https://www.runoob.com/w3cnote/awk-built-in-functions.html>

常用的：

- `length [(String)]`

返回 String 参数指定的字符串的长度（字符形式）。如果未给出 String 参数，则返回整个记录的长度（$0 记录变量）。

#### 求和

```shell
seq 1 10 | awk '{s+=$1} END {print s}'
```

来源：<https://stackoverflow.com/questions/450799/shell-command-to-sum-integers-one-per-line>

#### 打印到stderr

```awk
print "Serious error detected!" > "/dev/stderr"
```

官方文档：<https://www.gnu.org/software/gawk/manual/html_node/Special-FD.html>

#### [exit](https://www.gnu.org/software/gawk/manual/html_node/Exit-Statement.html)

```awk
exit [return code]
```

#### [next](https://www.gnu.org/software/gawk/manual/html_node/Next-Statement.html)

立即停止处理当前record，开始处理下一个record。

### column

`cat table | column -t`可以输出一个漂亮的表格。

来源：<https://stackoverflow.com/a/28755377/13688160>

### comm

求两个有序文件中的相同行和不同行。第一列是只在第一个文件中的行，第二列是只在第二个文件中的行，第三列是两个文件都存在的行。常用命令行选项：

- `-1`: 不输出第一列
- `-2`: 不输出第二列
- `-3`: 不输出第三列

参考：<https://unix.stackexchange.com/questions/28865/list-the-difference-and-overlap-between-two-plain-data-set>

### cp

把指定文件夹下面的所有文件和目录复制到另一个文件夹：

```shell
cp -a source/. dest
```

来源：<https://askubuntu.com/a/86891>

### cut

```text
       -d, --delimiter=DELIM
              use DELIM instead of TAB for field delimiter

       -f, --fields=LIST
              select  only these fields;  also print any line that contains no delimiter character, unless the -s option is speci‐
              fied

       -s, --only-delimited
              do not print lines not containing delimiters
```

典型用法：

```shell
# 用空格分隔，打印第二个field
echo "hello world" | cut -sd" " -f2
```

### diff

忽略换行符的区别：`--strip-trailing-cr`

来源：<https://stackoverflow.com/questions/40974170/how-can-i-ignore-line-endings-when-comparing-files>

### dpkg

#### 显示当前已经安装的软件

```shell
dpkg --list
```

#### 查看文件由哪个包提供

```shell
$ dpkg -S /bin/ls
coreutils: /bin/ls
```

来源：<https://askubuntu.com/a/482>

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
```

#### 查找规则

- `-name`: 根据文件名查找（精确查找）

- `-iname`: 不区分大小写

- `!`: 逻辑取反，比如`\! -name "xxx"`就是查找名字跟`xxx`不匹配的项

#### 查找示例

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

#### 正则

`查找规则`部分：`-regex '正则表达式'`

正则表达式匹配的是完整路径。

例子：

```shell
find . -regex '.*/latency-[0-9]*'
```

```text
./latency-2
./latency-4
./latency-3
./latency-5
./latency-1
./latency-6
./latency-7
./latency-0
```

来源：<https://stackoverflow.com/questions/6844785/how-to-use-regex-with-find-command>

### grep

```text
       -v, --invert-match
              Invert the sense of matching, to select non-matching lines.
       -m NUM, --max-count=NUM
              Stop reading a file after NUM matching lines.  If  the  input  is  standard
              input  from a regular file, and NUM matching lines are output, grep ensures
              that the standard input is positioned to just after the last matching  line
              before exiting, regardless of the presence of trailing context lines.  This
              enables a calling process to resume a search.  When grep  stops  after  NUM
              matching  lines,  it  outputs  any  trailing context lines.  When the -c or
              --count option is also used, grep does not output a count greater than NUM.
              When  the  -v  or  --invert-match  option  is  also  used, grep stops after
              outputting NUM non-matching lines.
```

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

`--exclude`, `--exclude-dir`: <https://www.warp.dev/terminus/grep-exclude>

- 正则: `-E`

里面不支持`\d`之类的，只支持`[0-9]`

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

刷新：`shift+R`

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

### rm

`-d`: 当目录为空时才删除目录。

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

### top

`-H`: 显示单个线程。<https://serverfault.com/questions/38195/getting-a-per-thread-cpu-stats>

## 其他

{% post_link shell/'zsh使用笔记' %}

[linux中怎么用shell显示文件某一行或几行内容](https://blog.csdn.net/mydriverc2/article/details/82623778)

[linux shell 将多行文件转换为一行](https://blog.csdn.net/hjxhjh/article/details/17264739)

`[`和`[[`的区别：<https://stackoverflow.com/questions/3427872/whats-the-difference-between-and-in-bash>
