---
title: Linux获取线程CPU使用情况
date: 2023-11-14 21:11:30
tags:
---

相关：{% post_link shell/'Linux获取进程cpu使用情况' %}

## CPU使用率

用`pidstat`:

```shell
pidstat -p 线程tid -H -u 间隔秒数 -t | awk '{if ($4 == 线程tid) print $9}'
```

## 累积CPU time

可以用`clock_gettime`得到CPU时间戳，两个CPU时间戳相减就是中间的CPU time。

### 获取当前线程的CPU时间戳

```cpp
clock_gettime(CLOCK_THREAD_CPUTIME_ID, &currTime)
```

### 获取其他线程的CPU时间戳

通过thread ID可以得到clockid:

```cpp
int pthread_getcpuclockid(pthread_t thread, clockid_t *clockid);
```

`std::thread`的thread ID可以通过`std::thread::native_handle()`得到。自己的thread ID可以通过`pthread_self()`得到。

获取`std::thread`的CPU时间戳的例子：

```cpp
#include <iostream>
#include <atomic>
#include <cassert>
#include <condition_variable>
#include <ctime>
#include <mutex>
#include <thread>
#include <vector>

#include <pthread.h>

static inline time_t cpu_timestamp_ns(clockid_t clockid) {
  struct timespec t;
  if (-1 == clock_gettime(clockid, &t)) {
    perror("clock_gettime");
	return 0;
  }
  return t.tv_sec * 1000000000 + t.tv_nsec;
}

static void foo(
	size_t secs, std::atomic<size_t> *finished, const bool *permit_join,
	std::condition_variable *cv, std::mutex *mu
) {
	std::this_thread::sleep_for(std::chrono::seconds(secs));

	finished->fetch_add(1, std::memory_order_relaxed);
	std::unique_lock<std::mutex> lock(*mu);
	// 等到外面不再读取自己的cpu time再结束，不然clock_gettime会报错
	cv->wait(lock, [permit_join]() { return *permit_join; });
}

int main() {
	constexpr size_t num_threads = 8;
	std::atomic<size_t> finished(0);
	bool permit_join = false;
	std::condition_variable cv;
	std::mutex mu;
	std::vector<std::thread> ts;
	std::vector<clockid_t> clock_ids;
	for (size_t i = 0; i < num_threads; ++i) {
		// 让这些thread sleep不同的时间
		ts.emplace_back(foo, i, &finished, &permit_join, &cv, &mu);
		pthread_t thread_id = ts[i].native_handle();
		clockid_t clock_id;
		assert(pthread_getcpuclockid(thread_id, &clock_id) == 0);
		clock_ids.push_back(clock_id);
	}
	// 每个线程最开始的时间戳
	std::vector<time_t> ori;
	for (size_t i = 0; i < num_threads; ++i) {
		ori.push_back(cpu_timestamp_ns(clock_ids[i]));
	}
	while (finished.load(std::memory_order_relaxed) != num_threads) {
		time_t tot = 0;
		for (size_t i = 0; i < num_threads; ++i) {
			// 当前时间戳减去开始的时间戳就是中间经过的CPU time
			tot += cpu_timestamp_ns(clock_ids[i]) - ori[i];
		}
		std::cerr << tot << " ns" << std::endl;
		std::this_thread::sleep_for(std::chrono::seconds(1));
	}
	{
		std::unique_lock<std::mutex> lock(mu);
		permit_join = true;
	}
	cv.notify_all();
	for (size_t i = 0; i < num_threads; ++i) {
		ts[i].join();
	}

	return 0;
}
```

参考：<https://stackoverflow.com/a/44917411/13688160>

### ps (不推荐)

```shell
ps -eT -o tid,cputimes | awk '{if ($1 == 线程tid) print $2}'
```

```text
       tid         TID       the unique number representing a dispatchable entity (alias lwp, spid).  This value
                             may also appear as: a process ID (pid); a process group ID (pgrp); a session ID for
                             the session leader (sid); a thread group ID for the thread group leader (tgid); and
                             a tty process group ID for the process group leader (tpgid).

       cputimes    TIME      cumulative CPU time in seconds (alias times).
```

主要问题是太耗CPU了。执行一次大约要耗费0.01秒的CPU时间。
