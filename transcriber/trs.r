REBOL[]

;This is the script to generate a HTML document from TRS files.  It is currently made to do something specific to a Transcriber and word document combination.   

alert "Please select the original language (_o) TRS file"
o-page: read to-file o-file-name: request-file
alert "Please select the morphological-tag (_m) TRS file"
m-page: read to-file m-file-name: request-file
alert "Please select the english (_e) TRS file"
e-page: read to-file e-file-name: request-file
o-data: ""
m-data: ""
o-table: []
m-table: []
e-table: []

parse e-page [
	some [ copy chi to newline thru newline copy eng to newline thru newline (insert/only tail e-table reduce [eng chi])
	] to end
]

de-filename: func [filename /local x] [
	x: to-string filename
	x: parse x {/}
	first parse pick x (length? x) "."
]

doc-name: parse (de-filename o-file-name) "_" 
doc-name: doc-name/1


parse/all o-page [any [to {<Sync time="0"/>} copy page-data to {</Turn>} (insert o-data page-data)] to end ]
parse/all m-page [any [to {<Sync time="0"/>} copy page-data to {</Turn>} (insert m-data page-data)] to end ]

o-parse-rules: [
	some [
		[thru {<Sync time="} copy timecode to {"} thru newline copy datum to newline (insert/only tail o-table reduce [de-filename o-file-name datum timecode])]
	]
	 to end 
]
m-parse-rules: [
	some [
		[thru {<Sync time="} copy timecode to {"} thru newline copy datum to newline (insert/only tail m-table reduce [de-filename m-file-name datum timecode])]
	]
	 to end 
]

parse/all o-data o-parse-rules
parse/all m-data m-parse-rules

combined-table: []

repeat i (length? o-table) [
	insert/only tail combined-table (pick o-table i)
	insert/only tail combined-table (pick m-table i)
	if (not none? (pick e-table i)) [ 
		insert/only tail combined-table reduce [rejoin [doc-name "_e"] (pick pick e-table i 1) (pick pick o-table i 3) ]
		insert/only tail combined-table reduce [rejoin [doc-name "_c"] (pick pick e-table i 2) (pick pick o-table i 3) ]
	]
]


generate-html: func [data-block /local html-string html-tail] [
	html-string: {
<html>
	<body>
	<p>Title & info</p>
	<table border="1">
}
	html-tail: {
	</table>
	</body>
</html>
}

	generate-tr: func [fst snd trd] [
		rejoin [ "	<tr>^/		<td> " fst "</td>^/		<td>" snd "</td>^/		<td>" trd "</td>^/	</tr>^/ "]
	]

	foreach row data-block [
		if (not none? row) [
			if ((length? row) = 2) [
				append tail html-string generate-tr row/1 " " row/2		
			]
			if ((length? row) = 3) [
				append tail html-string generate-tr row/1 row/2 row/3
			]
		]
	]

	append tail html-string html-tail
	write %tester.html html-string
]

generate-html combined-table

halt