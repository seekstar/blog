---
title: 0xffffffffc1131d1d in ?? () Cannot find bounds of current function
date: 2021-01-23 00:38:06
---

其实并不是崩了，只是gdb找不到目前在哪一行而已。为了验证，输入```l```命令打印附近的代码
```
(gdb) n
Cannot find bounds of current function
(gdb) l
221             unsigned long i;
222             int ret = 0;
223
224             while (a * 5 < (1 << max_bits_a)) {
225                     a = a * 5;
226                     ++thread_num;
227             }
228             thread_num = 1UL << floor_log_2(thread_num);
229             thread_num = NOVA_MIN(thread_num, sbi->cpus);
230             printk("Init blockmap using %lu threads\n", thread_num);
(gdb) n
Cannot find bounds of current function
(gdb) l
231             data = kmalloc(thread_num * sizeof(struct do_init_blockmap_data), GFP_KERNEL);
232             if (data == NULL) {
233                     ret = -ENOMEM;
234                     goto out;
235             }
236             tasks = kzalloc(thread_num * sizeof(struct task_struct *), GFP_KERNEL);
237             if (tasks == NULL) {
238                     ret = -ENOMEM;
239                     goto out;
240             }
```
可以看到行数改变了，说明没有崩。

所以尝试降低优化等级，再试就正常了。

相关：<https://stackoverflow.com/questions/3082570/debugging-with-bochs-gdb-cannot-find-bounds-of-current-function>
