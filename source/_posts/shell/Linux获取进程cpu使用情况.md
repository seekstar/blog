---
title: Linux获取进程cpu使用情况
date: 2023-07-01 14:38:32
tags:
---

相关：{% post_link shell/'Linux获取线程CPU使用情况' %}

## CPU使用率

### pidstat (推荐)

```shell
pidstat -p 进程PID -H -u 间隔秒数 | awk '{if(NR>3){print $1,$8}}'
```

- `-H`: Display timestamp in seconds since the epoch.
- `-u`: Report CPU utilization.
- `NR>3`: 第四行开始才是有效输出。

awk可能需要加上`fflush(stdout)`: {% post_link shell/'awk-fflush' %}

### top

```shell
top -b -p 进程PID -d 间隔秒数
```

`-b`: Batch mode.

配合`awk`等可以把CPU使用率给提取出来，但是由于CPU使用率在哪一列是根据`~/.toprc`确定的，所以要做到portable很麻烦。

### ps (不推荐)

注意，这个方法只能用来获取整个进程生命周期的平均CPU使用率。

```shell
ps -q 进程PID -o %cpu
```

输出：

```text
%CPU
52.3
```

```text
       %cpu        %CPU      cpu utilization of the process in "##.#" format.  Currently, it is the CPU time used
                             divided by the time the process has been running (cputime/realtime ratio), expressed
                             as a percentage.  It will not add up to 100% unless you are lucky.  (alias pcpu).
```

## 累积CPU time

### C/C++: `clock_gettime`

获取当前进程的CPU时间戳：

```c
static inline time_t process_cpu_timestamp_ns() {
  struct timespec t;
  if (-1 == clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t)) {
    perror("clock_gettime");
    return 0;
  }
  return t.tv_sec * 1000000000 + t.tv_nsec;
}
```

两个CPU时间戳相减就是中间进程消耗的CPU time。

### ps

累积CPU time的秒数：

```shell
ps -q 进程PID -o cputimes
```

```text
       cputimes    TIME      cumulative CPU time in seconds (alias times).
```

## 参考文献

<https://www.baeldung.com/linux/process-periodic-cpu-usage>
