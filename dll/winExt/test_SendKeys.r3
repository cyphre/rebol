REBOL [
	Title: "Win Extension Test"
	author: "Jocko"
	date: 2-Nov-2009
	comment: {
	test and demo of the use of winExt.dll
	this test file is focused on sendkeys commands
	}
]
; this is a a list of all the keywords processed by sendkeys
keywords: ["ENTER" "BACK" "TAB" "SHIFT" "CTRL" "ALT" "CTRL+ALT" "CTRL+SHIFT" "CTRL+ALT+SHIFT" "ALT+SHIFT" 
"CTRL_LOCK" "CTRL_UNLOCK" "ALT_LOCK" "ALT_UNLOCK" "SHIFT_LOCK" "SHIFT_UNLOCK" "PAUSE" "CAPSLOCK" 
"CAPSLOCK_ON" "CAPSLOCK_OFF" "ESC" "PAGEUP" "PAGEDOWN" "END" "HOME" "LEFT" "UP" "RIGHT" "DOWN" 
"PRINTSCRN" "INSERT" "DELETE" "LWIN" "RWIN" "APPS" "NUMPAD0" "NUMPAD1" "NUMPAD2" "NUMPAD3" "NUMPAD4" 
"NUMPAD5" "NUMPAD6" "NUMPAD7" "NUMPAD8" "NUMPAD9" "F1" "F2" "F3" "F4" "F5" "F6" "F7" "F8" "F9" "F10"
"F11" "F12" "NUMLOCK" "NUMLOCK_ON" "NUMLOCK_OFF" "SCROLLLOCK" "SCROLLLOCK_ON" "SCROLLLOCK_OFF" 
"REPEAT" "END_REPEAT" "DELAY"]



secure [extension allow]
t: import %winExt.dll
print " "
print rejoin ["dll version " w-version]

;w-minimize-all

print " "
print "--- launch Notepad and send keys to the window ---"

w-launch "notepad.exe" 
; w-launch-dir "notepad" "Mes Documents"
wait 1
hNotepad: w-find-window  "Bloc-notes"
w-sendkeys hNotepad "Hello World !<ENTER><ENTER><REPEAT 3>REBOL is fantastic !<ENTER><END_REPEAT>"

wait 1
w-sendkeys hNotepad "Hello you"
wait 1
w-sendkeys hNotepad "<BACK><BACK><BACK>"
w-sendkeys hNotepad "<UP><LEFT>"
w-sendkeys hNotepad  "..."
wait 4

w-close hNotepad
wait 1


ask "quit ?"
