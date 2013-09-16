REBOL [
	
]

print mold system/script/args


;;
;;	print collect [foreach f [%redo.reb %12as] [if exists? f [keep f]]] 

;;print map-each f [%redo.reb %12as] [either exists? f [f] [()]]
print map-each f [%redo.reb %12as] [either exists? f [f] [continue]]


redo: funct [][
	call/wait {ghc "/Users/kealist/Documents/GitHub/Haskell/redo/redo"}

]


print "Exiting"