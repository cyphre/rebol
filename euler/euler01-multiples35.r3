REBOL [
	Author: "Joshua Shireman"
	Title: 
	Date: Jul-14-2013
	Version: 0.0.1
]

multiples-3-5: func [x /blk] [
	blk: copy []
	t: 0
	for i 0 x - 1 1[
		if (((i // 3) = 0) or ((i // 5) = 0)) [
			append blk i
			;print i
		]
	]
	foreach n blk [
		t: t + n 
	]
	t
]

multiples-3-5 10
multiples-3-5 1000
