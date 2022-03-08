---
title: Linux kernel rhashtable基础用法
date: 2022-03-08 11:53:39
tags:
---

以5.1.0为例。

## 简单的key

`test1.c`:

```c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/rhashtable.h>

MODULE_LICENSE("GPL");

struct hash_entry {
	struct rhash_head node;
	u32 key;
	u64 value;
};

void hash_entry_free(void *ptr, void *arg) {
	kfree(ptr);
}

static int __init start_init(void)
{
	u32 i;
	struct hash_entry *entry;
	struct rhashtable_params param = {
		.key_len = sizeof(u32),
		.key_offset = offsetof(struct hash_entry, key),
		.head_offset = offsetof(struct hash_entry, node),
		.automatic_shrinking = true,
	};
	struct rhashtable rht;
	int ret = rhashtable_init(&rht, &param);
	printk("rhashtable_init returns %d\n", ret);
	if (ret < 0)
		return ret;
	for (i = 0; i < (1 << 26); ++i) {
		entry = kzalloc(sizeof(struct hash_entry), GFP_KERNEL);
		if (entry == NULL) {
			printk("kzalloc returns NULL\n");
			goto err_exit;
		}
		entry->key = i;
		entry->value = (u64)i * i;
		//printk("Inserting %u %llu\n", entry->key, entry->value);
		ret = rhashtable_insert_fast(&rht, &entry->node, param);
		if (ret < 0) {
			kfree(entry);
			printk("rhashtable_insert_fast returns %d\n", ret);
			goto err_exit;
		}
	}
	for (i = 0; i < (1 << 26); ++i) {
		// 如果可以保证entry不被删掉，那么可以用rhashtable_lookup_fast
		entry = rhashtable_lookup_fast(&rht, &i, param);
		if (entry == NULL) {
			printk("rhashtable_lookup_fast returns NULL\n");
			goto err_exit;
		}
		if (entry->value != (u64)i * i) {
			printk("%u %llu\n", i, entry->value);
			goto err_exit;
		}

		// 如果另一个线程可能会删掉entry，那么需要一直拿着read lock直到不再需要entry
		rcu_read_lock();
		entry = rhashtable_lookup(&rht, &i, param);
		if (entry == NULL) {
			printk("rhashtable_lookup returns NULL\n");
			goto err_exit;
		}
		if (entry->value != (u64)i * i) {
			printk("%u %llu\n", i, entry->value);
			goto err_exit;
		}
		rcu_read_unlock();
	}
err_exit:
	rhashtable_free_and_destroy(&rht, hash_entry_free, NULL);
	return 0;
}

static void __exit end_exit(void)
{
}

module_init(start_init)
module_exit(end_exit)
```

```Makefile
obj-m += test1.o
all:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=`pwd`
clean:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=`pwd` clean
```

```shell
make
sudo insmod test1.ko
sudo rmmod test1
dmesg | less
```

```text
[  340.782852] rhashtable_init returns 0
```

正常完成。

## 间接存储的key

比方说entry里只存key的指针之类的。这里方便起见，将key存到KV pair里。

由于key是间接存储的，`rhashtable`不知道怎么把key读出来，所以需要提供`obj_hashfn`用于从entry中算出key的哈希值，还需要提供`obj_cmpfn`用于确定这个entry的key是不是跟给定的key一致。注意，这里仍然需要提供`key_len`，我也不知道为什么。。。

`test1.c`:

```c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/rhashtable.h>

MODULE_LICENSE("GPL");

struct kvpair {
	u64 key;
	u64 value;
};

struct hash_entry {
	struct rhash_head node;
	struct kvpair kv;
};

void hash_entry_free(void *ptr, void *arg)
{
	kfree(ptr);
}

u32 hashfn(const void *data, u32 len, u32 seed)
{
	return jhash(data, len, seed);
}

u32 hash_entry_hashfn(const void *data, u32 len, u32 seed)
{
	struct hash_entry *entry = (struct hash_entry *)data;
	return jhash(&entry->kv.key, sizeof(entry->kv.key), seed);
}

// Function to compare key with object
int key_entry_cmp(struct rhashtable_compare_arg *arg, const void *obj)
{
	struct hash_entry *entry = (struct hash_entry *)obj;
	return *(u64 *)arg->key - entry->kv.key;
}

static int __init start_init(void)
{
	u64 i;
	struct hash_entry *entry;
	struct rhashtable_params param = {
		.key_len = sizeof(u64),
		.head_offset = offsetof(struct hash_entry, node),
		.hashfn = hashfn,
		.obj_hashfn = hash_entry_hashfn,
		.obj_cmpfn = key_entry_cmp,
		.automatic_shrinking = true,
	};
	struct rhashtable rht;
	int ret = rhashtable_init(&rht, &param);
	printk("rhashtable_init returns %d\n", ret);
	if (ret < 0)
		return ret;
	for (i = 0; i < (1 << 26); ++i) {
		//entry = kmalloc(sizeof(struct hash_entry), GFP_KERNEL);
		entry = kzalloc(sizeof(struct hash_entry), GFP_KERNEL);
		if (entry == NULL) {
			printk("kzalloc returns NULL\n");
			goto err_exit;
		}
		entry->kv.key = i;
		entry->kv.value = i * i;
		//printk("Inserting %llu %llu\n", entry->key, entry->value);
		ret = rhashtable_insert_fast(&rht, &entry->node, param);
		if (ret < 0) {
			kfree(entry);
			printk("rhashtable_insert_fast returns %d\n", ret);
			goto err_exit;
		}
	}
	for (i = 0; i < (1 << 26); ++i) {
		// 如果可以保证entry不被删掉，那么可以用rhashtable_lookup_fast
		entry = rhashtable_lookup_fast(&rht, &i, param);
		if (entry == NULL) {
			printk("rhashtable_lookup_fast returns NULL\n");
			goto err_exit;
		}
		if (entry->kv.value != i * i) {
			printk("%llu %llu\n", i, entry->kv.value);
			goto err_exit;
		}

		// 如果另一个线程可能会删掉entry，那么需要一直拿着read lock直到不再需要entry
		rcu_read_lock();
		entry = rhashtable_lookup(&rht, &i, param);
		if (entry == NULL) {
			printk("rhashtable_lookup returns NULL\n");
			goto err_exit;
		}
		if (entry->kv.value != (u64)i * i) {
			printk("%llu %llu\n", i, entry->kv.value);
			goto err_exit;
		}
		rcu_read_unlock();
	}
err_exit:
	rhashtable_free_and_destroy(&rht, hash_entry_free, NULL);
	return 0;
}

static void __exit end_exit(void)
{
}

module_init(start_init)
module_exit(end_exit)
```

`Makefile`和编译运行的步骤跟上面一样。
