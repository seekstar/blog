---
title: C语言内嵌汇编学习笔记
date: 2020-02-27 14:29:22
---

参考：
gnu gcc中关于Extended Asm的文档
<https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html>
Basic Asm文档
<https://gcc.gnu.org/onlinedocs/gcc/Basic-Asm.html#Basic-Asm>

这里只谈Extended Asm。
Extended Asm的基本语法：
```
asm asm-qualifiers ( AssemblerTemplate 
                 : OutputOperands 
                 [ : InputOperands
                 [ : Clobbers ] ])
```
其中asm-qualifiers是修饰符，常用的有volatile，表示不要优化。

AssemblerTemplate 是汇编模板，可以有多条（一般用"\n\t"隔开）。OutputOperands是输出，InputOperands是输入，Clobbers是受影响的东西。

# Assembler Template
AssemblerTemplate 里引用C语言变量时可以使用编号，比如```%i```表示OutputOperands和InputOperands里的第i个变量。
例子：
```c
uint32_t Mask = 1234;
uint32_t Index;

  asm ("bsfl %1, %0"
     : "=r" (Index)
     : "r" (Mask)
     : "cc");
 ```
%0就是Index，%1就是Mask。
所以这段代码的意思是把Mask的最高的"1"位的下标存入Index中。
参考：<https://blog.csdn.net/zdl1016/article/details/8763803>

也可以使用名字。例子：
```c
uint32_t Mask = 1234;
uint32_t Index;

  asm ("bsfl %[aMask], %[aIndex]"
     : [aIndex] "=r" (Index)
     : [aMask] "r" (Mask)
     : "cc");
 ```
其中aIndex可以直接换为Index，aMask可以直接换为Mask。

# Output Operands
一个operand的格式如下：
```
[ [asmSymbolicName] ] constraint (cvariablename)
```
不同的operand之间用逗号隔开。

## prefix
Output operands的constraint必须以```=```或```+```开始。
```=```: 把结果写入
```+```: 既读又写。此时这个operand不需要在Input Operands里出现。

## additional constraints
文档：<https://gcc.gnu.org/onlinedocs/gcc/Constraints.html#Constraints>
常用：
m: 允许内存操作数
r: 允许通用寄存器
i: 允许立即数

# Input Operands
一个operand的格式如下：
```
[ [asmSymbolicName] ] constraint (cexpression)
```

## constrain
没有prefix
- 数字（例如i）：表示这个输入操作数的物理位置必须与第i个输出操作数的物理位置一致。
```c
asm ("combine %2, %0" 
   : "=r" (foo) 
   : "0" (foo), "g" (bar));
```
- 方括号括起来的变量名：表示这个输入操作数的物理位置必须与这个变量名对应的输出操作数的物理位置一致。
```c
asm ("cmoveq %1, %2, %[result]" 
   : [result] "=r"(result) 
   : "r" (test), "r" (new), "[result]" (old));
```
- 其他（与Output operands的constrain一样）


## Clobbers
一些常见的：
- cc: 修改了标志寄存器
- memory: 进行了除Input operands和Output operands外的内存读写。可用于实现read/write memory barrier。

例：<linux/compiler-gcc.h>
```c
#define barrier() __asm__ __volatile__("": : :"memory")
```
一篇关于内存屏障的好文章：<https://blog.csdn.net/maotianwang/article/details/9154159>

内存屏障有效率问题。所以如果知道会读写哪些内存，就可以在Input operands和Output operands里指定，而不需要使用"memory"。
例子：
假设指令```vecmul x, y, z```含义是```*z++ = *x++ * *y++```，那么写成内嵌汇编应该是
```c
asm ("vecmul %0, %1, %2"
     : "+r" (z), "+r" (x), "+r" (y), "=m" (*z)
     : "m" (*x), "m" (*y));
```
这样虽然进行了内存读取，但是在Input operands和Output Operands范围内，不需要使用开销很大的"memory"。
同理，如果知道只会读后面的10个字节，可以把Input operand写成这样：
```c
"m" (*(const char (*)[10]) p)
```

# 标号
来源：<https://fishc.com.cn/thread-39609-1-1.html>
je   1f或者je   1b   是跳转到对应的标号的地方 
这里的1表示标号(label),f和b表示向前还是向后,f(forward）向前（下），b(backward)向后 （上）

吐个槽，这个前后是真的迷，不如叫上下。

# 解读
## clflush
<asm/special_insns.h>
```c
static inline void clflush(volatile void *__p)
{
	asm volatile("clflush %0" : "+m" (*(volatile char __force *)__p));
}
```
clflush: cache line flush
文档：<https://c9x.me/x86/html/file_module_x86_id_30.html>
博客（中文）：<https://blog.csdn.net/u014800094/article/details/51150718?ops_request_misc=%7B%22request%5Fid%22%3A%22158277765519726867802802%22%2C%22scm%22%3A%2220140713.130056874..%22%7D&request_id=158277765519726867802802&biz_id=0&utm_source=distribute.pc_search_result.none-task>

```clflush(p)```的含义简单来说就是把包含p指向的内存的cache line写入内存，然后将这个cache line无效化，也就是说今后读取这个cache line对应的部分时都要重新从内存中读取。

"+m"指读写内存。
<https://stackoverflow.com/questions/36226627/why-does-clflush-needs-m-constant>
