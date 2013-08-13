REBOL []

load-gui

for i 105 106 1 [
	print i
	img: make image! reduce [to-pair reduce [i i] white]
	repeat num i [poke img to-pair reduce [0 num - 1] red]
	repeat num i [poke img to-pair reduce [i - 1 num - 1] red]
	repeat num i [poke img to-pair reduce [num - 1 0] red]
	repeat num i [poke img to-pair reduce [num - 1 i - 1] red]
	view layout [image img]
]