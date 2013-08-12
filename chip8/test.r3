REBOL[]

load-gui

img: make image! reduce [30x30 black]

view m: layout [
	button "start" on-action [
	    code: [
			img/rgb: random 255.255.255
			draw-face/now i
		] 
		set 't set-timer/repeat code  0:00:00.016666666
	]
	button "stop" on-action [
		clear-timer t
	]
	i: image img 
]
