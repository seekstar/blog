---
title: 算法竞赛中rust的一种比较健壮的读入
date: 2020-08-25 23:53:13
tags:
---

以PAT 甲级1004为例

关键部位

```rust
fn main() {
    loop {
        let mut input = String::new();
        if 0 == io::stdin().read_line(&mut input).unwrap() {
            break;
        }
        let input = input.trim();
        if input.len() == 0 {
            continue;
        }
        let mut s = input.split_whitespace();
        let n: usize = s.next().unwrap().parse().unwrap();
        if 0 == n {
            break;
        }
        let m: usize = s.next().unwrap().parse().unwrap();
        work(n, m);
    }
}
```

这样遇到空行也不会panic。

![在这里插入图片描述](算法竞赛中rust的一种比较健壮的读入/20200825235216969.png#pic_center)
注意有一组测试数据是用非空格或者多个空格隔开的，所以要用```split_whitespace```。

ps: 还可以用BufReader加速stdin读取：<https://seekstar.github.io/2021/11/17/rust%E7%94%A8bufreader%E5%8A%A0%E9%80%9Fstdin%E8%AF%BB%E5%8F%96/>

完整代码：
```rust
use std::io;
use std::cmp;

fn dfs(mut cnt: &mut Vec<usize>, cur: usize, depth: usize, childs: &Vec<Vec<usize>>) -> usize {
    if childs[cur].is_empty() {
        cnt[depth] += 1;
        return depth + 1;
    }
    let mut mx = 0usize;
    for v in &childs[cur] {
        let v = *v;
        mx = cmp::max(mx, dfs(&mut cnt, v, depth + 1, &childs));
    }
    return mx;
}

fn work(n: usize, m: usize) {
    let mut childs = vec![Vec::new(); n + 1];
    for _i in 0..m {
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        let mut s = input.trim().split_whitespace();
        let fa: usize = s.next().unwrap().parse().unwrap();
        let num: usize = s.next().unwrap().parse().unwrap();
        for _i in 0..num {
            let c: usize = s.next().unwrap().parse().unwrap();
            childs[fa].push(c);
        }
    }
    let mut cnt = vec![0usize; n + 10];
    let depth = dfs(&mut cnt, 1, 0, &childs);
    print!("{}", cnt[0]);
    for i in 1..depth {
        print!(" {}", cnt[i]);
    }
    println!();
}

fn main() {
    loop {
        let mut input = String::new();
        if 0 == io::stdin().read_line(&mut input).unwrap() {
            break;
        }
        let input = input.trim();
        if input.len() == 0 {
            continue;
        }
        let mut s = input.split_whitespace();
        let n: usize = s.next().unwrap().parse().unwrap();
        if 0 == n {
            break;
        }
        let m: usize = s.next().unwrap().parse().unwrap();
        work(n, m);
    }
}
```
