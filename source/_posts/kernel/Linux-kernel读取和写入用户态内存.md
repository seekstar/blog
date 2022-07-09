---
title: Linux kernel读取和写入用户态内存
date: 2022-06-26 17:08:22
tags:
---

`copy_from_user`和`copy_to_user`底层都是`copy_user_generic`。其主体部分是正常复制数据，但是访问用户态数据时，可能会出现page fault，这时硬件会自动跳转到内核提供的page fault handler `do_page_fault`，将page准备好之后再跳回原来的指令继续执行。但是如果page fault处理失败了，比如这不是一个valid address，那么内核会搜索这条指令对应的fixup point，如果找到了，就跳转到这个fixup point。

参考：<https://www.kernel.org/doc/Documentation/x86/exception-tables.txt>

`copy_user_generic`根据CPU的特性有三种实现：

```c
static __always_inline __must_check unsigned long
copy_user_generic(void *to, const void *from, unsigned len)
{
	unsigned ret;

	/*
	 * If CPU has ERMS feature, use copy_user_enhanced_fast_string.
	 * Otherwise, if CPU has rep_good feature, use copy_user_generic_string.
	 * Otherwise, use copy_user_generic_unrolled.
	 */
	alternative_call_2(copy_user_generic_unrolled,
			 copy_user_generic_string,
			 X86_FEATURE_REP_GOOD,
			 copy_user_enhanced_fast_string,
			 X86_FEATURE_ERMS,
			 ASM_OUTPUT2("=a" (ret), "=D" (to), "=S" (from),
				     "=d" (len)),
			 "1" (to), "2" (from), "3" (len)
			 : "memory", "rcx", "r8", "r9", "r10", "r11");
	return ret;
}
```

如果有`ERMS`（Enhanced REP MOVSB/STOSB instructions），就用`copy_user_enhanced_fast_string`；否则，如果有`REP`指令，就用`copy_user_generic_string`；否则用通用的`copy_user_generic_unrolled`。

内嵌汇编详解：{% post_link C/'C语言内嵌汇编学习笔记' %}。`ASM_OUTPUT2`中，`=`表示既读又写，`D`表示`di`，作为第一个函数参数，`S`表示`si`，作为第二个函数参数，`d`表示`dx`，作为第三个函数参数，`a`表示`ax`，作为返回值。`"1" (to), "2" (from), "3" (len)`其实是`Input Operands`，其中`1`、`2`、`3`分别表示对应的输入操作数的物理位置必须与第1、2、3个输出操作数的物理位置一致。`"memory", "rcx", "r8", "r9", "r10", "r11"`是`Clobbers`，表示内存、`rcx`、`r8`、`r9`、`r10`、`r11`的内容被修改了。

## `copy_user_enhanced_fast_string`

现代CPU通常有`ERMS`，所以先看`copy_user_enhanced_fast_string`：

```asm
/*
 * Some CPUs are adding enhanced REP MOVSB/STOSB instructions.
 * It's recommended to use enhanced REP MOVSB/STOSB if it's enabled.
 *
 * Input:
 * rdi destination
 * rsi source
 * rdx count
 *
 * Output:
 * eax uncopied bytes or 0 if successful.
 */
ENTRY(copy_user_enhanced_fast_string)
	// Set AC
	ASM_STAC
	cmpl $64,%edx
	// .L_copy_short_string在copy_user_generic_unrolled的实现里。
	jb .L_copy_short_string	/* less then 64 bytes, avoid the costly 'rep' */
	// 把第三个参数edx赋值给ecx，用作rep指令的counter。
	movl %edx,%ecx
	// rep movsb其实可以看作是一条指令，表示将si指向的cx个数据拷贝到di指向的位置。
	// 相当于while (cx != 0) {*di++ = *si++; cx--}
	// 参考：https://stackoverflow.com/questions/43343231/enhanced-rep-movsb-for-memcpy
1:	rep
	movsb
	// 将返回值eax清零
	xorl %eax,%eax
	// Clear AC
	ASM_CLAC
	ret

	.section .fixup,"ax"
	// 此时ecx保存了没有被拷贝的字节数。将其赋值给edx，即作为copy_user_handle_tail的第三个参数。
12:	movl %ecx,%edx		/* ecx is zerorest also */
	// rdi和rsi分别是第一和第二个参数。
	jmp copy_user_handle_tail
	.previous

	// 如果指令1（即rep movsb）出错了，就跳转到指令12（即fixup section）
	_ASM_EXTABLE_UA(1b, 12b)
ENDPROC(copy_user_enhanced_fast_string)
```

STAC: Set AC。CLAC: Clear AC。参考：<https://www.felixcloutier.com/x86/stac>

`copy_user_handle_tail`可以看作是尽量多复制一些字节，从而精准定位到出错的那个字节：

```c
/*
 * Try to copy last bytes and clear the rest if needed.
 * Since protection fault in copy_from/to_user is not a normal situation,
 * it is not necessary to optimize tail handling.
 */
__visible unsigned long
copy_user_handle_tail(char *to, char *from, unsigned len)
{
	for (; len; --len, to++) {
		char c;

		if (__get_user_nocheck(c, from++, sizeof(char)))
			break;
		if (__put_user_nocheck(c, to, sizeof(char)))
			break;
	}
	clac();
	return len;
}
```

## `copy_user_generic_string`

```c
ENTRY(copy_user_generic_string)
	ASM_STAC
	cmpl $8,%edx
	jb 2f		/* less than 8 bytes, go to byte copy loop */
	ALIGN_DESTINATION
	movl %edx,%ecx
	shrl $3,%ecx
	andl $7,%edx
1:	rep
	movsq
2:	movl %edx,%ecx
3:	rep
	movsb
	xorl %eax,%eax
	ASM_CLAC
	ret

	.section .fixup,"ax"
11:	leal (%rdx,%rcx,8),%ecx
12:	movl %ecx,%edx		/* ecx is zerorest also */
	jmp copy_user_handle_tail
	.previous

	_ASM_EXTABLE_UA(1b, 11b)
	_ASM_EXTABLE_UA(3b, 12b)
ENDPROC(copy_user_generic_string)
```

与`copy_user_enhanced_fast_string`差不多，主要是先进行了`rep movsq`，即先以8字节为单位做拷贝，再`rep movsb`，即逐字节拷贝。

## `copy_user_generic_unrolled`

```c
/*
 * copy_user_generic_unrolled - memory copy with exception handling.
 * This version is for CPUs like P4 that don't have efficient micro
 * code for rep movsq
 *
 * Input:
 * rdi destination
 * rsi source
 * rdx count
 *
 * Output:
 * eax uncopied bytes or 0 if successful.
 */
ENTRY(copy_user_generic_unrolled)
	ASM_STAC
	cmpl $8,%edx
	jb 20f		/* less then 8 bytes, go to byte copy loop */
	ALIGN_DESTINATION
	movl %edx,%ecx
	andl $63,%edx
	shrl $6,%ecx
	jz .L_copy_short_string
1:	movq (%rsi),%r8
2:	movq 1*8(%rsi),%r9
3:	movq 2*8(%rsi),%r10
4:	movq 3*8(%rsi),%r11
5:	movq %r8,(%rdi)
6:	movq %r9,1*8(%rdi)
7:	movq %r10,2*8(%rdi)
8:	movq %r11,3*8(%rdi)
9:	movq 4*8(%rsi),%r8
10:	movq 5*8(%rsi),%r9
11:	movq 6*8(%rsi),%r10
12:	movq 7*8(%rsi),%r11
13:	movq %r8,4*8(%rdi)
14:	movq %r9,5*8(%rdi)
15:	movq %r10,6*8(%rdi)
16:	movq %r11,7*8(%rdi)
	leaq 64(%rsi),%rsi
	leaq 64(%rdi),%rdi
	decl %ecx
	jnz 1b
.L_copy_short_string:
	movl %edx,%ecx
	andl $7,%edx
	shrl $3,%ecx
	jz 20f
18:	movq (%rsi),%r8
19:	movq %r8,(%rdi)
	leaq 8(%rsi),%rsi
	leaq 8(%rdi),%rdi
	decl %ecx
	jnz 18b
20:	andl %edx,%edx
	jz 23f
	movl %edx,%ecx
21:	movb (%rsi),%al
22:	movb %al,(%rdi)
	incq %rsi
	incq %rdi
	decl %ecx
	jnz 21b
23:	xor %eax,%eax
	ASM_CLAC
	ret

	.section .fixup,"ax"
30:	shll $6,%ecx
	addl %ecx,%edx
	jmp 60f
40:	leal (%rdx,%rcx,8),%edx
	jmp 60f
50:	movl %ecx,%edx
60:	jmp copy_user_handle_tail /* ecx is zerorest also */
	.previous

	_ASM_EXTABLE_UA(1b, 30b)
	_ASM_EXTABLE_UA(2b, 30b)
	_ASM_EXTABLE_UA(3b, 30b)
	_ASM_EXTABLE_UA(4b, 30b)
	_ASM_EXTABLE_UA(5b, 30b)
	_ASM_EXTABLE_UA(6b, 30b)
	_ASM_EXTABLE_UA(7b, 30b)
	_ASM_EXTABLE_UA(8b, 30b)
	_ASM_EXTABLE_UA(9b, 30b)
	_ASM_EXTABLE_UA(10b, 30b)
	_ASM_EXTABLE_UA(11b, 30b)
	_ASM_EXTABLE_UA(12b, 30b)
	_ASM_EXTABLE_UA(13b, 30b)
	_ASM_EXTABLE_UA(14b, 30b)
	_ASM_EXTABLE_UA(15b, 30b)
	_ASM_EXTABLE_UA(16b, 30b)
	_ASM_EXTABLE_UA(18b, 40b)
	_ASM_EXTABLE_UA(19b, 40b)
	_ASM_EXTABLE_UA(21b, 50b)
	_ASM_EXTABLE_UA(22b, 50b)
ENDPROC(copy_user_generic_unrolled)
```

就是一个做了循环展开的拷贝。
