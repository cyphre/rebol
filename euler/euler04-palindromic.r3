REBOL [
	Title: "Largest Palindromic Product"
	Author: "Joshua Shireman"
	Date: Jul-14-2013
	Version: 0.0.1
]


palindromic?: func [x] [
	ret: true
	l: length? x: to-string x
	for i 1 ((l / 2)) 1 [
		;print i
		if (not equal? (q: pick x i) (r: pick x (l - i + 1))) [ret: false]
		;print [q r]
	]
	ret
]

for i 999 800 -1 [
	for j 999 800 -1 [
		if (palindromic? (i * j)) [print [i j] return [i j] ]
	]
]

palindromic? "12"