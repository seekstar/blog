---
title: javascript学习笔记
date: 2023-01-30 22:42:11
tags:
---

字体颜色和样式之类的定义在CSS里。

## EJS检测变量是否存在

```html
<% if (theme.sidebar.headerPrefix) { %>
	<script>
		// 如果存在，就将headerPrefix赋值为它。
		var headerPrefix = '<%- theme.sidebar.headerPrefix %>';
	</script>
<% } else { %>
	<script>
		// 否则赋值为默认值
		var headerPrefix = '<i class="fa fa-circle" aria-hidden="true"></i>';
	</script>
<% } %>
```

然后`headerPrefix`就可以在之后的javascript脚本里访问。

## EJS中`<%=`和`<%-`的区别

`<%=`转义，`<%-`不转义。

来源：<https://stackoverflow.com/questions/11024840/ejs-versus>

## TypeError: _my_lib.default is not a function

import { gen_index_of } from "./components/lib/my.lib";
一定要加{}，如果写成
import  gen_index_of  from "./components/lib/my.lib";
会报错：
TypeError: _my_lib.default is not a function

my_lib.js

```js
export function shuffle(arr) {
    let i = arr.length;
    while (i) {
        let j = Math.floor(Math.random() * i--);
        [arr[j], arr[i]] = [arr[i], arr[j]];
    }
}

export function gen_index_of(arr) {
    var index_of = {};
    for (let i = 0; i < arr.length; ++i) {
        index_of[arr[i]] = i;
    }
    return index_of;
}

export function shallow_copy_array(arr) {
    var ret = [];
    for (let v of arr) {
        ret.push(v);
    }
    return ret;
}
```
