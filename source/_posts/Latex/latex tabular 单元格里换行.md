---
title: latex tabular 单元格里换行
date: 2020-07-17 09:58:57
tags:
---

参考：<https://blog.csdn.net/zjccsg/article/details/51926067>

```tex
\newcommand{\tabincell}[2]{
    \begin{tabular}{@{}#1@{}}
        #2
    \end{tabular}
}
```
@{}表示把这一侧的空格给去掉：<https://tex.stackexchange.com/questions/233938/what-is-the-use-of/233957>

测试：
```tex
\begin{table}[H]
\begin{tabular}{ccc}
    \hline
    栈 & 输入 & 动作说明 \\
    \hline
    \tabincell{l}{0 \\ \#} & abab\# & action(0, a) = s3 \\
    \hline
    \tabincell{l}{03 \\ \#a} & bab\# & action(3, b) = s4 \\
    \hline
    \tabincell{l}{034 \\ \#ab} & ab\# & action(4, a) = r4 \\
    \hline
    \tabincell{l}{03 \\ \#aB} & ab\# & goto(3, B) = 6 \\
    \hline
    \tabincell{l}{036 \\ \#aB} & ab\# & action(6, a) = r3 \\
    \hline
    \tabincell{l}{0 \\ \#B } & ab\# & goto(0, B) = 2 \\
    \hline
    \tabincell{l}{02 \\ \#B} & ab\# & action(2, a) = s3 \\
    \hline
    \tabincell{l}{023 \\ \#Ba } & b\# & action(3, b) = s4 \\
    \hline
    \tabincell{l}{0234 \\ \#Bab } & \# & action(4, \#) = r4 \\
    \hline
    \tabincell{l}{023 \\ \#BaB } & \# & goto(3, B) = 6 \\
    \hline
    \tabincell{l}{0236 \\ \#BaB } & \# & action(6, \#) = r3 \\
    \hline
    \tabincell{l}{02 \\ \#BB } & \# & goto(2, B) = 2 \\
    \hline
    \tabincell{l}{022 \\ \#BB } & \# & action(2, \#) = r2 \\
    \hline
    \tabincell{l}{022 \\ \#BBA } & \# & goto(2, A) = 5 \\
    \hline
    \tabincell{l}{0225 \\ \#BBA } & \# & action(5, \#) = r1 \\
    \hline
    \tabincell{l}{02 \\ \#BA} & \# & goto(2, A) = 5 \\
    \hline
    \tabincell{l}{025 \\ \#BA} & \# & action(5, \#) = r1 \\
    \hline
    \tabincell{l}{0 \\ \#A} & \# & goto(0, A) = 1 \\
    \hline
    \tabincell{l}{01 \\ \#A} & \# & action(1, \#) = acc \\
    \hline
\end{tabular}
\end{table}
```
![在这里插入图片描述](latex%20tabular%20单元格里换行/20200717095833630.png)
