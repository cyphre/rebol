REBOL[]

change-dir %/C/Users/joshua/Dropbox/kellydiss/segmented 
files: read %.
f: %/C/Users/joshua/Dropbox/kellydiss/all-cpp-data.txt

if (exists? f) [delete f]
write/append f reduce ["filename" tab "CPP-mean" tab newline] 

foreach file files [

		;; This part is only working with the .f0c files!
	if ((pick (q: parse file ".") 2) = "f0c") [

		;; loads the data and breaks it into a big block!
		txt: read file
		txt-p: parse txt none
		;; total - this is the total of the CPP values which will be averaged later 
		;; num - this is the number of values to calculate the mean
		total: 0
		num: 0 	
		;;each line has six items.  The last is cpp, i don't know what the others are.
		foreach [a b c d e cpp] txt-p [
			num: num + 1
			total: total + to-decimal cpp			
		]
		
		;; Calculate mean and append the data to the file 
		either (num = 0) [
			mean: "error"
		][
			mean: total / num
		] 
		write/append f reduce [file tab mean newline]
		print reduce [(pick q 1) "    "  mean]
	]	
]

print "Done!"

halt