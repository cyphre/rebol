REBOL[]
load-gui
img: make image! reduce [30x30 black]
view m: layout [
	button "start" on-action [
	    code: [
			img: make image! reduce [30x30 to-tuple reduce [random 255 random 255 random 255]] 
			set-face i img
		] 
		t: set-timer/repeat code  0:00:00.016666666
	]
	button "stop" on-action [clear-timer t]
	i: image img 
]

