---
title: rust fragment specifier
date: 2021-07-14 13:24:21
---

| Specifier | Description | Examples |
| ---- | ---- | ---- |
| ident | Identifier |	x, foo |
| path |	Qualified name |	std::collection::HashSet, Vec::new |
| ty |	Type |	i32, &T, Vec<(char, String)> |
| expr |	Expression |	2+2, f(42), if true { 1 } else { 2 } |
| pat |	Pattern |	_, c @ 'a' ... 'z', (true, &x), Badger { age, .. } |
| stmt |	Statement |	let x = 3, return 42 |
| block |	Brace-delimited block |	{ foo(); bar(); }, { x(); y(); z() } |
| item |	Item |	fn foo() {}, struct Bar;, use std::io; |
| meta |	Inside of attribute |	cfg!(windows), doc="comment" |
| tt |	Token tree |	+, foo, 5, [?!(???)] |

原文：<https://riptutorial.com/rust/example/5646/fragment-specifiers---kind-of-patterns>
