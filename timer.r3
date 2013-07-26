REBOL [
	author: "Joshua Shireman"
	title: "Simple SET-TIMER example"
]
load-gui

timer-hello: [print "hello"]
 
set-timer/repeat timer-hello 2 ;;think this is 2 seconds

view [text-area "blah blah"]

halt