REBOL [
	author: "Joshua Shireman"
	date: jul-20-2013
	title: "code generator"
]

sample-code: {# Add a product
# to the 'on-order' list
M AddProduct
F id	int
F name	char[30]
F order_code	int
E}
comment {
rebol-types: [
	"#"	";"
	"F" compose/deep [(var)]
	"M" compose/deep [(name) ": func [^/"]]
	"E" "^/"
]
}

args: copy []
comments: copy []

S: [
	thru "#" 
	skip
	copy comm to newline (append comments comm) 
]

M: [
	thru "M"
	skip
	copy name to newline 
]

F: [
	thru "F"
	skip
	copy var to newline (append args var)
]

E: [
	to "E"
	to end (print ["Comments:" probe comments "Function:" probe name newline "Arguments:" probe args])
]

rule: [
	some S
	1 M
	some F
	1 E	
]

parse sample-code rule


;probe args
;sample-code2: split sample-code newline
;foreach [t1 r1] rebol-types [
;	replace/all sample-code t1 r1
;]

;probe sample-code
