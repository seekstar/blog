---
title: sudo print multiple lines to file
date: 2022-10-07 23:32:40
tags:
---

```shell
sudo bash -c "cat > main.c" << EndOfMessage
int main() {
	printf("test\n");
	return 0;
}
EndOfMessage
cat main.c
```

```c
int main() {
        printf("test\n");
        return 0;
}
```

Reference: https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
