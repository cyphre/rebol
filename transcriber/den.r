REBOL[
	Title: "Denumbering Utterances"
	Author: "Joshua S Shireman"
	File:   %unicode.r
	Date: 16-Jun-2008
	Version: 0.3.0
]

#include %mezz.r
#include %prot.r
#include %view.r


alert "Choose an input file to denumber (html)"
if (error? try [test: read h: to-file request-file]) [alert "You must choose a file"]
log: ""

correct-length: 4
requested-number: 9999
flag: counter: 0
  

number-format: func [num type /local construct] [
	construct: copy ""
	;;; Type 1 is "0001)" "0002)"
	if (type = 1) [
		zeros: correct-length - length? to-string num
		repeat j zeros [
			insert tail construct "0"
		]
		insert tail construct num
		insert tail construct ")"
	]
	;;; Type 2 is "1)" "2)" 
	if (type = 2) [
		insert tail construct num
		insert tail construct ")"
	]
	if (type = 3) [
		zeros: 3 - length? to-string num
		repeat j zeros [
			insert tail construct "0"
		]
		insert tail construct num
		insert tail construct ")"
	]	
	construct
]

remove-number: func [num type data /local l] [
	if (type = 1) [
		remove remove remove remove remove data		
	]
	if (type = 2) [
		l: length? number-format num 2 
		repeat j l [remove data]
	]
	if (type = 3) [
		remove remove remove remove data
	]
]

denumbering: func [data type /local b] [
	repeat i requested-number [
		either b: find data number-format i type
			[
				flag: 1
				counter: 0
				remove-number i type b
			] [
				either (counter < 30) [
					counter: counter + 1
					insert tail log rejoin [(number-format i type) " not found" newline]
				] [break]
		]
	]
	data
]

write-file: does [
	alert "Choose an output file"
	write to-file request-file/save da
	write %denumbering-log.txt log
]

if (error? try [
	da: denumbering test 1
	if (flag = 0) [da: denumbering test 3]
	if (flag = 0) [da: denumbering test 2]
	write-file
	alert "Processed"
]) [alert "Error"]

quit
