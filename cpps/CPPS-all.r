REBOL[]

change-dir %/C/Users/joshua/Dropbox/kellydiss/segmented 
files: read %.


foreach file files [
	if ((pick (parse file ".") 2) = "wav") [
		h: reduce [%/C/Users/joshua/Dropbox/kellydiss/cpps.exe file]
		print h
		call h
		wait .1
	]
]

print "Done!"

halt