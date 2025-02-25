---
title: Autolab使用教程
date: 2025-02-25 00:14:50
tags:
---

搭建教程：{% post_link App/'Autolab搭建教程' %}

## SMTP

配置了SMTP才能在用户注册的时候发送confirmation email。

用root user登录进去之后，`Manage Autolab` -> `Configure Autolab` -> `SMTP CONFIG`

填完了之后点击`UPDATE CONFIGURATION`，配置才会生效。

可以在`Configuration Testing`里试试配置对不对：在`From`里填入助教邮箱，在`To`里填入要接收邮件的邮箱（可以跟`From`一样），然后点击`SEND TEST EMAIL`，如果能收到邮件说明成功了。

## 添加管理员

`Manage Autolab` -> `Manage Users`，点击要设置为管理员的用户，`EDIT INFORMATION`，勾上`Administrator`，`SAVE CHANGES`即可。

如果要把还没注册的用户设置成管理员：`Manage Autolab` -> `Manage Users` -> `CREATE USER`，然后填入Email, First name, Last name，勾选Administrator，`CREATE USER`。

## 添加课程

只有管理员才能添加课程。

`Manage Autolab` -> `Create New Course`

Late slack一般设置成3600秒，防止deadline的时候很多人提交导致服务器卡死。

之后可以在`Manage Course` -> `Course settings`里修改这些设置。

## 将学生加入课程

`Manage Course` -> `Manage course users` -> `ADD USERS FROM EMAILS`

## 添加作业

`Manage Course` -> `Install assessment` -> `Create New Assessment`

`Category name`是必填的，可以随便填一个，比如`Experiments`

在作业界面，`Edit assessment` -> `HANDIN`，`Handin filename`改成`submission.zip`。`Max size`默认2MB，可能有点太小了，建议改成128MB。改完之后`SAVE`。

`PENALTIES`里，`Max grace days`默认是0。一般把下面的`Allow unlimited grace days`勾上，不然课程grace day就白设置了。改完之后`SAVE`。

`PROBLEMS`里，`ADD PROBLEM`，一般只需要填`Name`和`Max score`。好像没办法直接导入，只能一个一个加。加完之后`SAVE`。

### Autograder

在`BASIC`里点击`Autograder`右边的加号，进入Autograder Settings，或者在作业界面点击`Autograder settings`。

#### 评测机制

autolab在评测同学提交的作业submission.zip的时候，会先通过指定的VM Image创建一个Docker container，然后把Autograder Makefile重命名成`Makefile`，把Autograder Tar重命名成`autograde.tar`，和`submission.zip`放在Docker container里的同一个空目录下面，然后执行`make`，要求它输出的最后一行形如:

```text
{"scores": {"问题1": 分数1, "问题2": 分数2, ..., "问题n": 分数n}}
```

autolab会解析这一行，用来打分。其中`问题n`对应之前`PROBLEMS`里输入的`Name`，分数的范围是0到`Max score`，可以是小数。

#### VM Image

假设我们要给这个作业的image叫`image_p0`。

我们在autolab的服务器上写一个`Dockerfile_p0`:

```Dockerfile
FROM debian:12

# git: clone Tango. Dependency of cpptrace
# sudo: needed when installing autodriver
# procps: pkill. Otherwise no feedback
# unzip: submission.zip
# python: grade.py
RUN apt-get update && apt-get install -y \
	git \
	build-essential \
	gcc \
	make \
	sudo \
	procps \
	unzip \
	python3 \
	python3-venv

# Install autodriver
WORKDIR /home
RUN useradd autolab
RUN useradd autograde
RUN mkdir autolab autograde output
RUN chown autolab:autolab autolab
RUN chown autolab:autolab output
RUN chown autograde:autograde autograde
RUN git clone --depth 1 https://github.com/autolab/Tango.git
WORKDIR Tango/autodriver
RUN make clean && make
RUN cp autodriver /usr/bin/autodriver
RUN chmod +s /usr/bin/autodriver

# Clean up
WORKDIR /home
RUN rm -rf Tango/

RUN python3 -m venv /home/.venvs/base
RUN echo ". /home/.venvs/base/bin/activate" >> /home/.profile
RUN . /home/.profile && pip3 install func-timeout

# assessment-specific packages
RUN apt-get update && apt-get install -y \
	sqlite3
```

```shell
sudo docker build -t image_p0 -f Dockerfile_p0 .
```

然后在autolab的`VM Image`里填入`image_p0`即可。

#### Autograder Makefile

我们可以创建一个通用的Autograder Makefile：

```Makefile
all: submission.zip autograde.tar
	if [ -f /home/.profile ]; then \
		. /home/.profile; \
	fi; \
	rm -rf handin; \
	mkdir handin; \
	unzip submission.zip -d handin; \
	mkdir -p autograde; \
	tar xf autograde.tar -C autograde; \
	cd autograde && ./driver

clean:
	rm -rf handin autograde

.PHONY: all clean
```

在这个Autograder Makefile中，我们把`submission.zip`解压到`handin`里，把`autograde.tar`解压到`autograde`里，然后执行`driver`来评测。

#### driver

一般我们把测试相关的文件放到autograde.tar里，在`driver`中把这些文件copy到`handin`里，防止学生篡改这些文件。然后再做编译之类的准备工作。最后调用`grade.py`评分。例子：

```sh
#!/usr/bin/env sh
set -e
# Overwrite essential files in case students tampered up them
cp -r essential/* ../handin/
cd ../handin
# 如果需要编译的话，在这里加上编译的命令
../autograde/grade.py
```

#### `grade.py`

我们可以写一个通用的`grade.py`，让它读取`config.json`来决定怎么评分，并且在超时时输出已经测完的问题的分数：

```py
#!/usr/bin/env python3
# Call this script in the handin folder

import sys
import os
import json
import subprocess

from func_timeout import FunctionTimedOut
from func_timeout.StoppableThread import StoppableThread

mydir = os.path.dirname(os.path.abspath(sys.argv[0]))
config = json.load(open(os.path.join(mydir, 'config.json')))

scores = {}

def run_tests():
    try:
        global scores
        for problem in config['problems']:
            executable = problem['exec']
            args = problem['args']
            process = subprocess.Popen([executable] + args)
            # We must wait with timeout, otherwise it won't respond to external exceptions.
            # https://stackoverflow.com/a/631605/13688160
            if process.wait(timeout=23333333) == 0:
                score = problem['score']
                print(problem['name'] + ' passed')
            else:
                score = 0
                print(problem['name'] + ' failed')
            scores[problem['name']] = score
    except FunctionTimedOut:
        try:
            process.kill()
        except NameError:
            pass
    except Exception as e:
        # Code to handle any other exception
        print("An error occurred: {}".format(str(e)))

tester = StoppableThread(target=run_tests)
tester.start()
tester.join(timeout=config['timeout'])
if tester.is_alive():
    tester.stop(exception=FunctionTimedOut)
    tester.join()
    print(f"The whole google test timed out after {config['timeout']} seconds")
    print("Please make your code faster.")

out = ''
for problem in config['problems']:
    if len(out) != 0:
        out += ', '
    if problem['name'] in scores:
        score = scores[problem['name']]
    else:
        score = 0
    out += '"' + problem['name'] + '": ' + str(score)
print('{"scores": {' + out + '}}')
```

#### `config.json`

示例：

```json
{
	"problems": [
		{
			"name": "问题1",
			"exec": "执行的文件（相对于handin的路径）",
			"args": ["参数1", "参数2", ...],
			"score": 分数
		},
	],
	"timeout": 120
}
```

#### Autograder Tar

建议的目录结构：

```text
XX-course
|- common
|  |- grade.py
|- p0
   |- .gitignore
   |- autograde.tar (ignore in .gitignore)
   |- config.json
   |- driver
   |- essential
   |  |-略
   |- Makefile
```

`p0/Makefile`:

```Makefile
files = driver config.json $(wildcard essential/*)
autograde.tar: ../common/grade.py $(files)
	tar cf autograde.tar $(files) -C ../common grade.py
```

以后在`p0`下面直接`make`就可以生成`autograde.tar`了。然后用`scp`之类的方法弄到本地，然后上传到autolab的Autograder Tar即可。
