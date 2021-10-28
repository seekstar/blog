---
title: javascript踩坑笔记
date: 2019-12-05 19:45:20
---

# TypeError: _my_lib.default is not a function
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
