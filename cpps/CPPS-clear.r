REBOL[]

change-dir %/C/Users/joshua/Dropbox/kellydiss/segmented 
files: read %. 

foreach file files [
	ext: pick (parse file ".") 2
	if any [
		ext = "f0c"
		ext = "wr"
		ext = "fc"	  
	][
		print reduce ["Deleted:  " file]
		delete file
	]	
]

print "Done!"

halt