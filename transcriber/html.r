REBOL [
	Author: "Joshua Shireman"
	Title: "Project HTML file parser"
	Date: Jul-17-2013
]

;; The purpose of this script is to process the HTML files our project was using to generate 
;; a dictionary based on multiple lines of  linguistically tagged language.
;; It generates two output files:
;; 1. output.txt : This is a tab-separated-values file that contains every morpheme that was processed correctly, along with it's relevant context
;; 2. problem-lines.txt : This is a list of all of the lines that needs the tags checked to meet specifications 


#include %mezz.r
#include %prot.r
#include %view.r


rem-html-crap: func [str] [
	parse str [
	    some [to "&nbsp;"
	       mark: (insert remove/part mark 6 " ")
	       :mark
  		]
	]
	parse str [
	    some [to "&#8217;"
	       mark: (insert remove/part mark 7 "'")
	       :mark
  		]
	]
] 

if (error? try [page: read to-file file-name: request-file]) [alert "You must select a file."  quit]

data-tables: []
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

remove-string: func [tgt str] [
	until [not remove/part find tgt str length? str]
]

parse/all page [any [to {<table} copy table to </table> (append data-tables table)] to end]

data-rows: []

foreach table data-tables [
	parse/all table [any [to {<tr} copy row to </tr> (insert tail data-rows row)] to end ]
]

data-block: []

original?: func [string /local str-blk] [
	str-blk: parse string "_~"
	remove-each str str-blk ["" = str]
	any [((last str-blk) = "o") ((last str-blk) = "O")]
]
morph-tag?: func [string /local str-blk] [
	str-blk: parse string "_~"
	remove-each str str-blk ["" = str]
	any [((last str-blk) = "m") ((last str-blk) = "M")]
]
eng-translation?: func [string /local str-blk] [
	str-blk: parse string "_~"
	remove-each str str-blk ["" = str]
	any [((last str-blk) = "e") ((last str-blk) = "dte") ((last str-blk) = "E")]	
]



foreach row data-rows [
	td: copy []
	detagged-td: copy []
	parse/all row [any [to {<td} copy datum to </td> (insert tail td datum)] to end ]		 
	foreach datum td [
		detagged-datum: remove-each item load/markup datum [tag? item]
		remove-each element detagged-datum [
			any [
				(equal? element "^/  ")
				(equal? element "&nbsp;")
				(equal? element " ")
			]
		]
		insert tail detagged-td rejoin detagged-datum
	]
	insert/only tail data-block detagged-td	
]

foreach row data-block [
	if not empty? row [	 
		remove-each char row/1 [(char = #"^/") or (char = #" ")]
		remove-each char row/2 [(char = #"^/")]
		parse row/1 [
		    some [to "&nbsp;"
		        mark: (remove/part mark 6)
	        :mark
  			]
		]
	]
]

generate-html: does [
	generate-tr: func [fst snd trd] [
		rejoin [ "	<tr>^/		<td> " fst "</td>^/		<td>" snd "</td>^/		<td>" trd "</td>^/	</tr>^/ "]
	]

	foreach row data-block [
		if ((length? row) = 2) [
			append tail html-string generate-tr row/1 " " row/2		
		]
		if ((length? row) = 3) [
			append tail html-string generate-tr row/1 row/2 row/3
		]
	]

	append tail html-string html-tail
	write %tester.html html-string
]

generate-morpheme-list: does [
	index: 1
	lgth: length? data-block
	while (lgth > index) [
		either (not any [
				(original? (a: pick pick data-block index 1))
				(morph-tag? a) 
				(eng-translation? a)
			]) [
				index: index+1
			] [
			try [
				o: pick data-block i
				m: pick data-block (i + 1)
				e: pick data-block (i + 2)	
								
				index: index + 1
			]	
		]			
	]	
]

morpheme-split: func [block code] [
	new-block: copy []
	either (code = 0) [hyph: "-"][hyph: ""] 
	foreach word block [
		w-p: parse word "-"
		remove-each word w-p [word = ""]
		if not ((l: (length? w-p)) = 1) [
			repeat j (length? w-p) [
				either (j = 1) [
					w-p/1: rejoin [w-p/1 hyph]
				] [
					either (j = l) [
						w-p/(j): rejoin [hyph (pick w-p j)] 
					] [
						w-p/(j): rejoin [hyph (pick w-p j) hyph]
					]
				]
			]
		]
		append new-block w-p
	]
	new-block
]

doc-name: parse (data-block/2/1) "_" 
doc-name: doc-name/1

real-ml: does [
	ml-output: reform ["morpheme" tab "gloss" tab "comments" tab "sample_S" tab "sample_S_gloss" tab "sample_S_trans" tab "sample_S_timestamp" tab "source" newline]
	not-matching: copy ""
	repeat i (length? data-block) [
		if (all [
				(original? (youa: pick pick data-block i 1))
				(morph-tag? (yous:  pick pick data-block (i + 1) 1))
				((length? pick data-block (i + 1)) = 3)
				((length? pick data-block i) = 3)
				]) [
			o: pick pick data-block i 2
			m: pick pick data-block (i + 1) 2
			e: copy ""
			if (error? try [	if (eng-translation? (pick pick data-block (i + 2) 1)) [e: pick pick data-block (i + 2) 2]		]) []
			o-p: parse o " "
			m-p: parse m " "
			o-p-m: morpheme-split o-p 0
			m-p-m: morpheme-split m-p 1
			rem-html-crap e 
			either (equal? (l: length? o-p-m) (length? m-p-m)) [
				repeat k l [
					insert tail ml-output reform [(pick o-p-m k) tab (pick m-p-m k) tab tab o tab m tab e tab (pick (pick data-block i) 3) tab doc-name newline]
				]
			] [
				insert tail not-matching reform ["----" newline (pick (pick data-block i) 3)  newline o newline m newline e newline]
			]
		]
	]
	write %output.txt ml-output
	write %problem-lines.txt not-matching
]

real-ml



;;;;;;;Functions
;probe-data
;generate-html
;generate-morpheme-list



comment {
	data-block is now a block (whole doc) of blocks (rows) of strings (table data cells).  I.E
	[	["Sprecher" "Beitrag " "Zeitraum "]
		["MNDLDA09Mar03a_o" "da Gena rjeba nege de mane" "0.0-9.49"]
		["MNDLDA09Mar03a_m" "CP old.day  SG LOC 1pl.GEN " "0.0-9.49"]
		["MNDLDA09Mar03a_e" "In the past," "0.0-9.49"]
		["MNDLDA09Mar03a_o" "e--- ndaiwa-ne zhawe negei-ce" "9.49-12.62"]	
		["MNDLDA09Mar03a_m" "VOL village-GEN monk one-COND" "9.49-12.62"]
		["MNDLDA09Mar03a_e" "if a monk is from  our village, " "9.49-12.62"]
		["MNDLDA09Mar03a_o" "e--- rjeba  zhacang de xouge dene rong" "12.62-15.21"]
		["MNDLDA09Mar03a_m" "CP tantric  college LOC enter do.PERF Nplace" "12.62-15.21"]
		["MNDLDA09Mar03a_e" "he would attend the Tantra College at Rongbo Monastery." "12.62-15.21"]
		["MNDLDA09Mar03a_o" "rong rjeba zhacang de xouge cang-ne mane ndaiwa-ne" "15.21-18.84"]
		["MNDLDA09Mar03a_m" {Nplace tantric college LOC when-PRT  1pl.GEN village-GEN} "15.21-18.84"]
	]
}
alert "Processed"

;] )[alert "error"]
