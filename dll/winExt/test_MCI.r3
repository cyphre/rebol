REBOL [
	Title: "Win Extension Test"
	author: "Jocko"
	date: 2-Nov-2009
	comment: {
	test and demo of the use of winExt.dll
	this test file is focused on MCI commands
	for more examples of MCI strings, see http://www.compguy.com/cwtip05.htm 
	For a complete specification, see Multimedia Programming Interface and Data Specifications 1.0
	}
]


secure [extension allow]
t: import %winExt.dll
print " "
print rejoin ["dll version " w-version]


print " "
print "--- list of MCI devices ---"

nItems: to-integer w-mci "sysinfo all quantity"
for iItem 1 nItems 1 [
	print w-mci rejoin ["sysinfo all name " iItem]
]

print " "
print "--- play audio from CD ---"
print " "
w-mci "open cdaudio"
trackNr: w-mci "status cdaudio number of tracks"
print rejoin ["nr of tracks : " trackNr]

w-mci "set cdaudio time format tmsf"
w-mci "play cdaudio from 3 to 5"
print w-mci "status cdaudio mode"
wait 5
ask "stop play ?"
w-mci "stop cdaudio"
w-mci "close cdaudio"

wait 2
print " "
print "--- play a video file ---"
w-mci "play ./media/butterfly.mpg"

wait 5
print " "
print "--- record from mic and play back  ---"

w-mci "open new type waveaudio alias capture"
; 16 bits per sample is better, but fails on some platforms ... 
;w-mci "set capture bitspersample 16" 
w-mci "record capture"
print w-mci "status capture mode"
print "please speak ... "
wait 5  ; record during 5 sec

print " "
print "--- save and play back  ---"
w-mci "save capture test.wav"
w-mci "close capture"

wait 1
w-mci "play test.wav"
print "record file name: test.wav"

ask "quit ?"

; --- to be sure ...
w-mci "close all"
