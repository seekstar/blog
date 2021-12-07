---
title: rust格式化打印到文件
date: 2021-07-05 09:58:41
---

用```write!```和```writeln!```即可。

```rust
write!(&mut writer, "Factorial of {} = {}", num, factorial);
```
```writeln!```就是在最后自动加一个换行。

原文：<https://stackoverflow.com/questions/32472495/how-do-i-write-a-formatted-string-to-a-file>
