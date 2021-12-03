---
title: rust BufReader逐字符读取
date: 2021-12-03 20:05:20
tags:
---

BufReader有一个```fill_buf```的方法：

```rs
fn fill_buf(&mut self) -> Result<&[u8]>
```

它可以返回它的内部buffer，如果buffer是空的，就填入更多数据再返回。这样我们就可以逐个读取其内部buffer的字符，且不需要额外申请空间了。

通过```fill_buf```返回的buffer处理完了一些数据之后，可以通过```consume```来告诉BufReader这些数据已经处理完了：

```rs
fn consume(&mut self, amt: usize)
```

它将前```amt```个字节从BufReader的buffer里删掉。

把```fill_buf```和```consume```结合起来，就可以逐字节读取了：

```rs
use std::io::{self, BufRead, BufReader};

fn main() {
    let mut cin = BufReader::new(io::stdin());
    loop {
        let len = if let Ok(buf) = cin.fill_buf() {
            if buf.is_empty() {
                break;
            }
            for c in buf {
                // Your code here
                println!("{}", c);
            }
            buf.len()
        } else {
            break;
        };
        cin.consume(len);
    }
}
```

输入：

```
abc
```


输出：

```
97
98
99
10
```

最后的```10```是换行符```LF```。

可以用闭包做一个wrapper：

```rs
use std::io::{self, BufRead, BufReader};

fn main() {
    let mut cin = BufReader::new(io::stdin());
    let peek = |r: &mut BufReader<_>| -> io::Result<Option<u8>> {
        let buf = r.fill_buf()?;
        if buf.is_empty() {
            Ok(None)
        } else {
            Ok(Some(buf[0]))
        }
    };
    while let Ok(Some(c)) = peek(&mut cin) {
        println!("{}", c);
        cin.consume(1);
    }
}
```

也可以写一个迭代器来实现类似于```getchar```和```peek```的效果：

```rs
use std::io::{self, Read, BufRead, BufReader};

struct MyReader<T> {
    r: BufReader<T>,
}

impl<T> From<BufReader<T>> for MyReader<T> {
    fn from(r: BufReader<T>) -> MyReader<T> {
        MyReader{r}
    }
}

impl<T: Read> MyReader<T> {
    fn peek(&mut self) -> io::Result<Option<u8>> {
        let buf = self.r.fill_buf()?;
        if buf.is_empty() {
            Ok(None)
        } else {
            Ok(Some(buf[0]))
        }
    }
}

impl<T: Read> Iterator for MyReader<T> {
    type Item = io::Result<u8>;
    fn next(&mut self) -> Option<Self::Item> {
        let res = self.r.fill_buf();
        match res {
            Ok(buf) => {
                if buf.is_empty() {
                    None
                } else {
                    let ret = buf[0];
                    self.r.consume(1);
                    Some(Ok(ret))
                }
            },
            Err(e) => Some(Err(e))
        }
    }
}

fn main() {
    let mut cin = MyReader::from(BufReader::new(io::stdin()));
    println!("{}", cin.peek().unwrap().unwrap());
    while let Some(Ok(c)) = cin.next() {
        println!("{}", c);
    }
}
```

输入：

```
abc
```

输出：

```
97
97
98
99
10
```

或者复杂一点的，减少调用```consume```的次数（不知道会不会变快）：

```rs
use std::io::{self, Read, BufRead, BufReader};

struct MyReader<T> {
    r: BufReader<T>,
    head: usize,
}

impl<T> From<BufReader<T>> for MyReader<T> {
    fn from(r: BufReader<T>) -> MyReader<T> {
        MyReader{r, head: 0}
    }
}

impl<T: Read> Iterator for MyReader<T> {
    type Item = io::Result<u8>;
    fn next(&mut self) -> Option<Self::Item> {
        if self.head == self.r.buffer().len() {
            self.r.consume(self.head);
            let res = self.r.fill_buf();
            match res {
                Ok(buf) => {
                    if buf.is_empty() {
                        return None;
                    }
                    self.head = 0;
                },
                Err(e) => return Some(Err(e)),
            }
        }
        let ret = Some(Ok(self.r.buffer()[self.head]));
        self.head += 1;
        return ret;
    }
}

fn main() {
    let mut cin = MyReader::from(BufReader::new(io::stdin()));
    while let Some(Ok(c)) = cin.next() {
        println!("{}", c);
    }
}
```

参考文献：rust BufReader官方文档：<https://doc.rust-lang.org/stable/std/io/struct.BufReader.html>
