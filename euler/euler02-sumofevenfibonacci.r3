REBOL [
	Title: "Even Fibonacci numbers"
	Author: "Joshua Shireman"
	Date: Jul-14-2013
	Version: 0.0.1
]

even-fibonacci-sum: func [x] [
	blk: copy [0 1]
	t: 0 
	while [(n: (first back tail blk) + (first back back tail blk)) < x] [
		append tail blk n
	]
	foreach i blk [
		if (even? i) [t: t + i]
	]
	t
]

even-fibonacci-sum 4000000