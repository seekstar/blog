---
title: rust格式控制
date: 2021-10-12 20:59:05
---

官方教程：<https://doc.rust-lang.org/std/fmt/>

注意，标准库里的格式控制字符串必须是字面量：
<https://www.reddit.com/r/rust/comments/48jzw0/formatting_with_a_static_string_literal/>
<https://stackoverflow.com/questions/46788199/how-to-create-a-constant-string-literal-in-rust>
<https://stackoverflow.com/questions/32572486/how-can-i-use-a-dynamic-format-string-with-the-format-macro>

如果想要动态的格式控制字符串，可以试试strfmt:
<https://github.com/vitiral/strfmt>
