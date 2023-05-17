---
title: rust运行shell命令并获取输出
date: 2021-08-17 17:53:28
---

```rust
use std::io::{BufReader, BufRead};
use std::process::{self, Command, Stdio};

fn main() {
    ls();
    ps();
    xargs();
    time();
    iostat();
}

// 不带参数命令
fn ls() {
    let output = Command::new("ls").output().expect("执行异常，提示");
    let out = String::from_utf8(output.stdout).unwrap();
    println!("{}", out);
}

// 带参数命令
fn ps() {
    // ps -q $$ -o %cpu,%mem
    let output = Command::new("ps")
        .arg("-q")
        .arg(process::id().to_string())
        .arg("-o")
        .arg("%cpu,%mem")
        .output()
        .unwrap();
    let out = String::from_utf8(output.stdout).unwrap();
    println!("{}", out);
}

// 复杂命令，直接扔进bash执行
fn xargs() {
    let mut cmd = "cat /proc/".to_string();
    cmd += &process::id().to_string();
    cmd += &"/stat | awk '{print $14,$15,$16,$17}'".to_string();
    let output = Command::new("bash")
        .arg("-c")
        .arg(cmd)
        .output()
        .unwrap();
    let out = String::from_utf8(output.stdout).unwrap();
    println!("utime stime cutime cstime");
    println!("{}", out);
}

// 手动实现管道
fn time() {
    let mut fname = "/proc/".to_string();
    fname += &process::id().to_string();
    fname += &"/stat".to_string();
    let child = Command::new("cat")
        .arg(fname)
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let output = Command::new("awk")
        .arg("{print $14,$15,$16,$17}")
        .stdin(child.stdout.unwrap())
        .output()
        .unwrap();
    let out = String::from_utf8(output.stdout).unwrap();
    println!("utime stime cutime cstime");
    println!("{}", out);
}

// 获取运行中的命令的输出
fn iostat() {
    let child = Command::new("iostat")
        .arg("1")
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let mut out = BufReader::new(child.stdout.unwrap());
    let mut line = String::new();
    while let Ok(_) = out.read_line(&mut line) {
        println!("{}", line);
    }
}
```


参考文献：

[rust：执行shell命令](https://blog.csdn.net/xkjscm/article/details/107405642)
<https://stackoverflow.com/questions/40836973/unable-to-use-stdprocesscommand-no-such-file-or-directory>
<https://www.reddit.com/r/rust/comments/3azfie/how_to_pipe_one_process_into_another/>
