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

rebol-types: [
	"#"	";"
	"F" [compose/deep [(var)]]
	"M" [compose/deep [(name) ": func [^/"]]
	"E" "^/]"
]

