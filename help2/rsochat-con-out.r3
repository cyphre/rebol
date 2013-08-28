Rebol [
	title: "Rebol Stack Overflow Chat Client"
	author: "Graham Chiu"
	rights: "BSD"
	date: [17-June-2013 19-June-2013 21-June-2013]
	version: 0.0.7
	instructions: {
	run at 21:40
            use the r3-view.exe client from Saphirion for windows currently at http://development.saphirion.com/resources/r3-view.exe
            and then just run this client

            do %rsochat.r3

            and then use the "Start" button to start grabbing messages

            ;This R2 script tickles the gui to grab messages
            ;tickle: does [ p: open/direct/lines tcp://localhost:8000 forever [ insert p "read" pick p 1 wait 0:00:5 ]]

          }
	history: {
            17-June-2013 first attempt at using text-table
            19-June-2013 using a server port to simulate a timer .. and gets a MS Visual C++ runtime error :(  So, back to using a forever loop with a wait
            21-June-2013 using a closure for the mini-http function appears to delay the crashes, removed unused code
          }

]

; load-gui

if not value? 'load-json [
	if not exists? %altjson.r3 [
		write %altjson.r3 read https://raw.github.com/gchiu/RSOChat/master/altjson.r3
	]
	do %altjson.r3
]

if not value? 'decode-xml [
	if not exists? %altxml.r3 [
		write %altxml.r3 read https://raw.github.com/gchiu/RSOChat/master/altxml.r3
	]
	do %altxml.r3
]

no-of-messages: 5
lastmessage-no: 10025800
wait-period: 3 ; seconds
tid-1: tid-2: none

bot-cookie: fkey: none

all-messages: []
last-message: make string! 100
lastmessage-no: 0

storage-dir: %messages/
if not exists? storage-dir [
	make-dir storage-dir
]

static-room-id: room-id: 291 room-descriptor: "rebol-and-red"

id-rule: charset [#"0" - #"9"]

so-chat-url: http://chat.stackoverflow.com/
profile-url: http://stackoverflow.com/users/
chat-target-url: rejoin write-chat-block: [so-chat-url 'chats "/" room-id "/" 'messages/new]
referrer-url: rejoin [so-chat-url 'rooms "/" room-id "/" room-descriptor]
html-url: rejoin [referrer-url "?highlights=false"]
read-target-url: rejoin [so-chat-url 'chats "/" room-id "/" 'events]
delete-url: [so-chat-url 'messages "/" (parent-id) "/" 'delete]


; perhaps not all of this header is required
header: [
	Host: "chat.stackoverflow.com"
	Origin: "http://chat.stackoverflow.com"
	Accept: "application/json, text/javascript, */*; q=0.01"
	X-Requested-With: "XMLHttpRequest"
	Referer: (referrer-url)
	Accept-Encoding: "gzip,deflate"
	Accept-Language: "en-US"
	Accept-Charset: "ISO-8859-1,utf-8;q=0.7,*;q=0.3"
	Content-Type: "application/x-www-form-urlencoded"
	cookie: (bot-cookie)
]

do load-config: func [] [
	either exists? %rsoconfig.r3 [
		rsoconfig: do load %rsoconfig.r3
		set 'fkey rsoconfig/fkey
		set 'bot-cookie rsoconfig/bot-cookie
	] [
		view [
			title "Enter the StackOverflow Chat Parameters"
			hpanel 2 [
				label "Fkey: " fkey-fld: field 120 ""
				label "Cookie: " cookie-area: area 400x80 "" options [min-hint: 400x80]
				pad 50x10
				hpanel [
					button "OK" on-action [
						either any [
							empty? fkey: get-face fkey-fld
							empty? cookie: get-face cookie-area
						]
						[alert "Both fields required!"]
						[
							either parse get-face cookie-area [to "usr=" copy cookie to "&" to end] [
								set 'bot-cookie get-face cookie-area
								set 'fkey get-face fkey-fld
								save %rsoconfig.r3 make object! compose [
									fkey: (fkey) bot-cookie: (bot-cookie)
								]
								close-window face
							] [
								alert "usr cookie not present"
							]
						]
					]
					button "Cancel" red on-action [
						close-window face
						halt
					]
				]
			]
		]
	]
]


unix-to-utc: func [unix [string! integer!]
	/local days d
] [
	if string? unix [unix: to integer! unix]
	days: unix / 24 / 60 / 60
	d: 1-Jan-1970 + days
	d/zone: 0:00
	d/second: 0
	d
]

utc-to-local: func [d [date!]] [
	d: d + now/zone
	d/zone: now/zone
	d
]

from-now: func [d [date!]] [
	case [
		d + 7 < now [d]
		d + 1 < now [join now - d " days"]
		d + 1:00 < now [d/time]
		d + 0:1:00 < now [join to integer! divide difference now d 0:1:00 " mins"]
		true [join to integer! divide now/time - d/time 0:0:1 " secs"]
	]
]

unix-now: does [
	60 * 60 * divide difference now/utc 1-Jan-1970 1:00
]

two-minutes-ago: does [
	subtract unix-now 60 * 2
]

image-cache: make block! 20

; how can we run this ??
update-icons: func [url
	/local icon-bar name image-url image link is-image? page gravatar-rule user-id index
] [
	digit: charset [#"0" - #"9"]
	digits: [some digit]
	icon-bar: copy []
	gravatar-rule: union charset [#"0" - #"9"] charset [#"a" - #"z"]
	page: to string! read url
	parse page [thru "update_user"
		some [
			thru "id:" some space copy user-id digits
			thru "name:" thru {("} copy name to {")} thru "email_hash:" thru {"} copy image-url to {"}
			(
				either not index: find image-cache user-id [
					is-image?: false
					case [
						#"!" = first image-url [
							is-image?: true
							remove image-url
							append image-url "?g&s=32"
						]
						parse image-url [some gravatar-rule] [
							is-image?: true
							image-url: ajoin [http://www.gravatar.com/avatar/ image-url "?s=32&d=identicon&r=PG"]
						]
					]
					if is-image? [
						link: read to-url image-url
						either find to string! copy/part link 4 "PNG" [
							image: decode 'PNG link
						] [
							image: decode 'JPEG link
						]
						append image-cache user-id
						repend/only image-cache [image name]
						repend icon-bar [image name]
						repend/only icon-bar ['set-face 'chat-area rejoin ["@" replace/all name " " "" " "] 'focus 'chat-area]
					]
				] [
					; user is in cache - we're not going to bother updating a user's image for the moment
					; index now points to the image-cache
					repend icon-bar select index user-id
					repend/only icon-bar ['set-face 'chat-area rejoin ["@" replace/all name " " "" " "] 'focus 'chat-area]
				]
			)
		]
	]
	icon-bar
]

grab-icons: func [url
	/local icon-bar name image-url image link is-image? page gravatar-rule
] [
	icon-bar: copy []
	gravatar-rule: union charset [#"0" - #"9"] charset [#"a" - #"z"]
	page: to string! read url
	parse page [thru "update_user"
		some [
			thru "name:" thru {("} copy name to {")} thru "email_hash:" thru {"} copy image-url to {"}
			(
				is-image?: false
				case [
					#"!" = first image-url [
						is-image?: true
						remove image-url
						append image-url "?g&s=32"
					]
					parse image-url [some gravatar-rule] [
						is-image?: true
						image-url: ajoin [http://www.gravatar.com/avatar/ image-url "?s=32&d=identicon&r=PG"]
					]
				]
				if is-image? [
					link: read to-url image-url
					either find to string! copy/part link 4 "PNG" [
						image: decode 'PNG link
					] [
						image: decode 'JPEG link
					]
					repend icon-bar [image name]
					repend/only icon-bar ['set-face 'chat-area rejoin ["@" replace/all name " " "" " "] 'focus 'chat-area]
				]
			)
		]
	]
	icon-bar
]
; mini-http is a minimalistic http implementation

mini-http: closure [url [url!] method [word! string!] code [string!] timeout [integer!]
	/callback cb
	/cookies cookie [string!]
	/local ; result url-obj payload port f-body
] [
	url-obj: http-request: payload: port: none
	unless cookies [cookie: copy ""]

	http-request: {$method $path HTTP/1.0
Host: $host
User-Agent: Mozilla/5.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
DNT: 1
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
X-Requested-With: XMLHttpRequest
Referer: http://$host
Content-Length: $len
Cookie: $cookie

$code}

	; Content-Type: text/plain; charset=UTF-8

	url-obj: construct/with sys/decode-url url make object! copy [port-id: 80 path: ""]
	if empty? url-obj/path [url-obj/path: copy "/"]

	payload: reword http-request reduce [
		'method form method
		'path url-obj/path
		'host url-obj/host
		'len length? code
		'cookie cookie
		'code code
	]
	
	port: make port! rejoin [
		tcp:// url-obj/host ":" url-obj/port-id
	]

	f-body: compose/deep copy/deep [

		timestamp:
		person-id:
		message-id:
		parent-id: 0
		user-name: make string! 20

		message-rule: [
			<event_type> quote 1 |
			<time_stamp> set timestamp integer! |
			<content> set content string! |
			<id> integer! |
			<user_id> set person-id integer! |
			<user_name> set user-name string! |
			<room_id> integer! |
			<room_name> string! |
			<message_id> set message-id integer! |
			<parent_id> set parent-id integer! |
			<show_parent> logic! |
			tag! skip |
			end
		]

		switch/default event/type [
			lookup [open event/port false]
			connect [
				write event/port (to binary! payload)
				event/port/locals: copy #{}
				false
			]
			wrote [read event/port false]
			read [
				append event/port/locals event/port/data
				clear event/port/data
				read event/port
				false
			]
			close done [
				if event/port/data [
					append event/port/locals event/port/data
				]
				result: to string! event/port/locals
				;attempt [

				if parse result [thru "^/^/" copy result to end] [
					if json: load-json/flat result [
						messages: json/2
						; now skip thru each message and see if any unread
						len: length? system/contexts/user/all-messages
						print now
						foreach msg messages [
							content: none
							user-name: none
							message-id: 0
							either parse msg [some message-rule] [
								content: trim decode-xml content
								?? message-id
								if all [
									integer? message-id
									not exists? join storage-dir message-id
								] [
									write join storage-dir message-id mold msg
								]
								if message-id > lastmessage-no [
									set 'lastmessage-no message-id
									repend/only system/contexts/user/all-messages [person-id message-id user-name content timestamp]
								]
							] [print ["failed parse" msg]]
						]
					]
				]

				true
			]
		] [true]
	]	
	port/awake: func [event /local result messages content message-no message-id data json user-name message-rule parent-id person-id timestamp] f-body
	open port
]

percent-encode: func [char [char!]] [
	char: enbase/base to-binary char 16
	parse char [
		copy char some [char: 2 skip (insert char "%") skip]
	]
	char
]

url-encode: use [ch mk] [
	ch: charset ["-." #"0" - #"9" #"A" - #"Z" #"-" #"a" - #"z" #"~"]
	func [text [any-string!]] [
		either parse/all text: form text [
			any [
				some ch | end | change " " "+" |
				mk: (mk: percent-encode mk/1)
				change skip mk
			]
		] [to-string text] [""]
	]
]

print "loading images"

tool-bar-data: grab-icons referrer-url

save/all %toolbar.r3 tool-bar-data

system/ports/system/awake: func [
	sport "System port (State block holds events)"
	ports "Port list (Copy of block passed to WAIT)"
	/local event port waked
] [
	debuger: open %out.txt
	waked: sport/data ; The wake list (pending awakes)
	
	write debuger reduce ["============================" newline]
	write debuger reduce [">>>>> Length is" (length? waked) newline]
	write debuger waked
	write debuger reduce [{-=-=-=-=-=-=-=-=-=-=-=-COMPLETE} newline]

	; Process all events (even if no awake ports).
	; Do only 8 events at a time (to prevent polling lockout).
	loop 8 [
		unless event: take sport/state [break]
		;Cyhre's note - Here check the EVENT value for EVENT/PORT - it crashes when it is invalid on then WAKE-UP call below
		; print ["event received at " now/precise ]
		either port? event/port [
			port: event/port
			if wake-up port event [
				; Add port to wake list:
				unless find waked port [append waked port]
			]
		] [
			print "malformed port"
			; print mold event/port
		]
	]

	write debuger reduce ["Finished Loop" newline "~~~~~~~~~~~~~~~~PORTS~~~~~~~~~~~~~~~~~~" newline]

	; No wake ports (just a timer), return now.
	unless block? ports [return none]
	write debuger mold ports
	ij: 0
	; Are any of the requested ports awake?
	forall ports [
		if port: find waked first ports [
			print (ij: ij + 1)
			remove port return true
		]
	]
	
	write debuger reduce [newline "END" newline newline]

	false ; keep waiting
]

forever [
	mini-http/cookies read-target-url 'POST rejoin ["since=0&mode=Messages&msgCount=" no-of-messages "&fkey=" fkey] 60 bot-cookie
	print ["end of fetch " now/precise]
	len: length? system/contexts/user/all-messages
	attempt [
		tool-data: update-icons referrer-url
		if tool-data <> tool-bar-data [
			print ["updating tool bar at " now]
			save/all %toolbar.r3 tool-data
			tool-data: none
		]
	]
	wait 2
]

halt

forever [
	print "next loop"
	t: open timer://
	t/awake: func [event] [
		print ["firing at " now/precise]
		mini-http/cookies read-target-url 'POST rejoin ["since=0&mode=Messages&msgCount=" no-of-messages "&fkey=" fkey] 60 bot-cookie
		print ["end of fetch " now/precise]
		len: length? system/contexts/user/all-messages
		attempt [
			tool-data: update-icons referrer-url
			if tool-data <> tool-bar-data [
				print ["updating tool bar at " now]
				save/all %toolbar.r3 tool-data
				tool-data: none
			]
		]
	]
	write t [3000] ; reduce [ wait-period * 1000 ]
	print ["waiting " reduce [wait-period * 1000] " at " now/precise]
	; attempt [wait 1 + wait-period]
	wait 3
	; close t
]

halt
