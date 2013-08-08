REBOL[
	title: "Chip 8 Emulator"
	author: "Joshua Shireman"
	version: 0.0.1
	date: Aug-08-2013
]

load-gui
pong: read %games/PONG
chip8: make object! [
	;;opcode must be 2 bytes
	opcode: none

	; 4k memory total
	;;;0x000-0x1FF - Chip 8 interpreter (contains font set in emu)
	;;;0x050-0x0A0 - Used for the built in 4x5 pixel font set (0-F)
	;;;0x200-0xFFF - Program ROM and work RAM

	memory: array 4096

	;CPU Register, 15 8-bit registers, 16th is carry flag
	v: array 16
	
	;index register I
	i: none

	; program counter PC
	pc: none

	gfx: array gfx-size: (64 * 32)
	gfx-scale: 10
	gfx-img: make image! reduce [to-pair reduce [64 * gfx-scale 32 * gfx-scale] white]
	draw-flag: false
	
	;Timers count at 60 Hz. When set above zero they will count down to zero
	;The system’s buzzer sounds whenever the sound timer reaches zero.
	delay-timer: to-binary [0]
	sound-timer: to-binary [0]

	stack: array 16
	sp: none

	key: array 16
	fontset: [ ;; see http://imgur.com/L3YxUmd
		#{F0} #{90} #{90} #{90} #{F0} ;;// 0
		#{20} #{60} #{20} #{20} #{70} ;;// 1
		#{F0} #{10} #{F0} #{80} #{F0} ;;// 2
		#{F0} #{10} #{F0} #{10} #{F0} ;;// 3
		#{90} #{90} #{F0} #{10} #{10} ;;// 4
		#{F0} #{80} #{F0} #{10} #{F0} ;;// 5
		#{F0} #{80} #{F0} #{90} #{F0} ;;// 6
		#{F0} #{10} #{20} #{40} #{40} ;;// 7
		#{F0} #{90} #{F0} #{90} #{F0} ;;// 8
		#{F0} #{90} #{F0} #{10} #{F0} ;;// 9
		#{F0} #{90} #{F0} #{90} #{90} ;;// A
		#{E0} #{90} #{E0} #{90} #{E0} ;;// B
		#{F0} #{80} #{80} #{80} #{F0} ;;// C
		#{E0} #{90} #{90} #{90} #{E0} ;;// D
		#{F0} #{80} #{F0} #{80} #{F0} ;;// E
		#{F0} #{80} #{F0} #{80} #{80} ;;// F
	]
	initialize: does [
		pc: 32
		opcode: to-binary [0]
		i: 1
		sp: to-binary [0]
		repeat num 4096 [poke memory num to-binary [0]]
		repeat num 16 [poke v num to-binary [0]]
		repeat num gfx-size [poke gfx num false]
		repeat num 16 [poke stack num to-binary [0]]
		
		;;load fontset
		repeat num 80 [poke memory num (pick fontset num)]
		
		;;reset timers
	]
	
	increment-pc: does [pc: pc + 2]
	
	fetch-opcode: does [
		return append (pick memory pc) (pick memory (pc + 1))
	]
	
	decode-opcode: func [oc /local n m w x] [
		switch/default (oc and #{F000}) [
			
			#{0000} [
				switch/default (oc and #{000F}) [
					#{0000} [					
						;;clear the screen
						gfx-img: make image! to-pair reduce [64 * gfx-scale 32 * gfx-scale] black
					]
					#{000E} [
						; returns from subroutine 
					]
					
				] [prin "ERROR: Unknown 0x0XXX OPCODE:" print oc]
			]
			
			#{1000} [
				;; Jumps to address NNN.
				oc and #{0FFF}
			]
			#{2000} [
				;; Calls subroutine at NNN.

				poke stack sp pc
				sp: sp + 1
				pc: oc and #{0FFF}
			]
			#{3000} [
				;; Skips the next instruction if VX equals NN.

			]
			#{4000} [
				;; Skips the next instruction if VX doesn't equal NN.

			]
			#{5000} [
				;; Skips the next instruction if VX equals VY.

			]
			#{6000} [
				;; Sets VX to NN.

			]
			#{7000} [
				;; Adds NN to VX.

			]
			#{8000} [
				switch/default (oc and #{000F}) [
					#{0000} [
					;8XY0;Sets VX to the value of VY.
					]
					#{0001} [
					;8XY1;Sets VX to VX or VY.
					]
					#{0002} [
					;8XY2;Sets VX to VX and VY.
					]
					#{0003} [
					;8XY3;Sets VX to VX xor VY.
					]
					#{0004} [
					;; 8XY4 adds register V[x] and V[y], setting v[16] flag if overflowed
						m: (1 + shift to-integer (oc and #{00F0}) -4)
						n: (1 + shift to-integer (oc and #{0F00}) -8)
						either (w: pick v m) > (255 - x: pick v n) [
							poke v 16 #{01}
						] [
							poke v 16 #{00}
						]
						poke v m (w + x)
						increment-pc
					]
					#{0005} [
					;8XY5;VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
					#{0006} [
					]
					;8XY6;Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.[2]
					]
					#{0007} [
					;8XY6;Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
					]
					#{000E} [
					;;Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.[2]
					]
				] [prin "ERROR: Unknown 0x8XXX OPCODE:" print oc]
			]
			#{9000} [
				;; Skips the next instruction if VX doesn't equal VY.

			]
			#{A000} [
				;;Sets I to the address NNN.
				i: (oc and #{0FFF})
				increment-pc
			]
			#{B000} [
				;;Jumps to the address NNN plus V0.
			]
			#{C000} [
				;;Sets VX to a random number and NN.
			]
			#{D000} [
				;;0xDXYN Draws a sprite at coordinate vx, vy that has a width of 8 pixels and a height of N pixels.  Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn’t happen.
				
				poke v 15 #{00}
				y: (1 + shift to-integer (oc and #{00F0}) -4)
				x: (1 + shift to-integer (oc and #{0F00}) -8)
				height: to-integer (oc and #{000F})
				repeat num height[
					;;this will make a string containing the pixels
					r: (pick memory (i + num - 1))
					w: enbase/base r 2
					repeat m 8 [
						z: first w
						if (z = #"1") [
							if ((pick gfx-img to-pair reduce [gfx-scale * (x + m - 1) gfx-scale * (y + num - 1)]) = black) 
								[poke v 15 #{01}]
							repeat num-y gfx-scale [
								repeat num-x gfx-scale [
									poke gfx-img to-pair reduce [(gfx-scale * (x + m - 1)) + num-x (gfx-scale * (y + num - 1)) + num-y] black
								]
							]
						]
						w: next w
					]
					
				]
				draw-flag: true				
			]
			#{E000} [
				switch/default (oc and #{00FF}) [
					#{009E} [
						;;Skips the next instruction if the key stored in VX is pressed.
						(oc and #{0F00})
					]
					#{00A1} [
						;;Skips the next instruction if the key stored in VX isn't pressed.
					]
				] [prin "ERROR: Unknown 0xEXXX OPCODE:" print oc]
			]
			#{F000} [
				switch/default (oc and #{00FF}) [
					#{0007} [
						;;Sets VX to the value of the delay timer.
					]
					#{000A} [
						;;A key press is awaited, and then stored in VX.
					]
					#{0015} [
						;;Sets the delay timer to VX.
					]
					#{0018} [
						;;Sets the sound timer to VX.
					]
					#{001E} [
						;;Adds VX to I.
					]
					#{0029} [
						;;Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
					]
					#{0033} [
						;; Stores BCD representation of VX at address I, I + 1 and I + 2
						m: to-integer pick v (1 + shift to-integer (oc and #{0F00}) -8) 
						poke memory i to-binary reduce [x: remainder m 10]
						poke memory (i + 1) to-binary reduce [((y: remainder m 100) - x) / 10]
						poke memory (i + 2) to-binary reduce [(m - y) / 100]
						increment-pc
					]
					#{0055} [
						;;Stores V0 to VX in memory starting at address I.
					]
					#{0066} [
						;;Fills V0 to VX with values from memory starting at address I.
					]
				] [prin "ERROR: Unknown 0XFXXX OPCODE:" print oc]
			]
		] [prin "ERROR: Unknown OPCODE:" print oc]
	]
	to-bcd: func [bin /local bcd-table w x y z] [
		bcd-table: [
			0	[2#{00000000}]
			1	[2#{00010001}]
			2	[2#{00100010}]
			3	[2#{00110011}]
			4	[2#{01000100}]
			5	[2#{01010101}]
			6	[2#{01100110}]
			7	[2#{01110111}]
			8	[2#{10001000}]
			9	[2#{10011001}]
		]
		w: to-integer bin
		x: remainder w 10
		y: ((remainder w 100) - x) / 10
		z: (w -(remainder w 100)) / 100
		append (#{00} or ((switch z bcd-table) and #{0F}))
			((switch x bcd-table) and #{0F}) or ((switch y bcd-table) and #{F0})
	]
	execute-opcode: does [

	]
	view-gfx: does [
		view layout [image gfx-img]
	]
	update-timers: does [
		
	]
	emulate-cycle: does [
		opcode: fetch-opcode
		decode-opcode opcode
		execute-opcode
		update-timers
	]
]

print "Chip 8 Emulator Starting..."

chip8/initialize

print "Chip 8 Emulator Initialized..."


print "Chip 8 Emulator Halting..."
halt