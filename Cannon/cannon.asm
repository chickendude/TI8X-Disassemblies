.nolist
#include "ti83plus.inc"
#include "ion.inc"
#include "keys.inc"
.list

.db t2ByteTok, tasmCmp
.org $9D95

; Ion header
	ret
	 jr nc, start
	.db "Cannon War 1.0",0

; Variables
p1_y = 0
p2_y = 1

p1_hp = 6
p2_hp = 7

; Program start
start:
	set 7, (iy + $14)

; Title screen
	ld bc, $0302			; 2,3
	ld (curRow), bc			; Set coordinates
	ld hl, title_txt
	bcall(_PutS)

	ld bc, $0404
	ld (curRow), bc
	ld hl, email1_txt
	bcall(_PutS)

	ld bc, $0305
	ld (curRow), bc
	ld hl, email2_txt
	bcall(_PutS)

; Long delay (probably should be changed to use halt)
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay

; Set up variables
	ld ix, saferamp
	ld (ix + p1_y), 8	; Player1's starting Y position
	ld (ix + p2_y), 56	; Player2's starting Y position
	ld (ix + 02), $00
	ld (ix + 03), $00
	ld (ix + 04), $08
	ld (ix + 05), $38
	ld (ix + p1_hp), 10 ; Player1 lives (starts at 10, but we dec 1 when displaying)
	ld (ix + p2_hp), 10 ; Player2 lives

	ld bc, $001D		; y = 0, x = 29
	ld (penCol), bc		; Store (pen/small) text coordinates
	ld hl, title_txt	; Address of text to draw
	bcall(_VPutS)		; Draw small text
	ld b, 1				; Height
	ld c, 12			; Width
	ld l, 7				; Y=7
	ld a, 0				; X=0
	push ix
		ld ix, long_bar_sprite
		call ionLargeSprite	; Draw the line underneath the title/score
	pop ix
	call player1_hit		; Subtracts life from player and draws new value to screen
	call player2_hit		; Same as above for player 2

main_loop:
; Check keys
	call clear_key_port
	ld a, Group1			; Group1: [Y=]->[Graph] and [2nd]/[Mode]/[Del]
	out (01), a				; Set group of keys to read (port 01 = key port)
	in a, (01)				; Read keys pressed in Group1 into a
	bit 4, a				; [Y=]
	push af					; > Save keys pressed
		call z, $9F21		;   Player1 fire
	pop af					; < Restore keys pressed back into a
	bit 5, a				; [2nd]
	push af
		call z, $9F0D
	pop af
	bit 0, a				; [Graph]
	push af
		call z, $9F46		; Player2 fire
	pop af

	call clear_key_port
	ld a, Group2			; Group2 (contains alpha)
	out (01), a
	in a, (01)
	cp dAlpha				; Check if [Alpha] was pressed
	push af
		call z, $9F17
	pop af

	call clear_key_port
	ld a, Group7			; Arrow keys
	out (01), a
	in a, (01)
	cp dDown
	push af
		call z, $9F3C
	pop af
	cp dUp
	push af
		call z, $9F32
	pop af

	call clear_key_port
	ld a, Group6			; Clear
	out (01), a
	in a, (01)
	cp dClear
	 jp z, $A00C			; Quit game if clear was pressed


	call $9FD9
	call $96CD
	call $9FD9
	ld a, $9C
	add a, (ix + 02)
	 jr nz, $9eb1
	call $9F57
	ld a, (ix + 04)
	add a, $FB
	cp (ix + p2_y)
	 jr nc, $9eb1
	ld a, (ix + 04)
	add a, 04
	cp (ix + p2_y)
	 jr c, $9eb1
	call      $9FA1
label_9eb1:
	ld        a, $A0
	add       a, (ix + 02)
	jr        nz, $9ebb
	call      $9F57
label_9ebb:
	ld        a, $9C
	add       a, (ix + 03)
	jr        nz, +_
	call      $9F6F
	ld        a, (ix + 05)
	add       a, $FB
	cp        (ix + p1_y)
	jr        nc, +_
	ld        a, (ix + 05)
	add       a, 04
	cp        (ix + p1_y)
	jr        c, +_
	call      $9F87
_:
	ld        a, $A0
	add       a, (ix + 03)
	jr        nz, +_
	call      $9F6F
_:
	ld        a, 00
	add       a, (ix + 02)
	jr        z, +_
	dec       (ix + 02)
_:
	ld        a, 00
	add       a, (ix + 03)
	jr        z, +_
	dec       (ix + 03)
_:
	ld        a, 00
	add       a, (ix + p1_hp)
	jp        z, $9FCA
	ld        a, 00
	add       a, (ix + p2_hp)
	 jp z, $9FBB
	jp main_loop

	ld        a, $F8
	add       a, (ix + p1_y)
	ret       z
	dec       (ix + p1_y)
	ret

	ld        a, $C8
	add       a, (ix + p1_y)
	ret       z
	inc       (ix + p1_y)
	ret

	ld        a, 00
	add       a, (ix + 02)
	 ret       nz
	ld        a, (ix + p1_y)
	ld        (ix + 04), a
	ld        (ix + 02), $64
	ret

	ld        a, $F8
	add       a, (ix + p2_y)
	ret       z
	dec       (ix + p2_y)
	ret

	ld        a, $C8
	add       a, (ix + p2_y)
	ret       z
	inc       (ix + p2_y)
	ret

	ld        a, 00
	add       a, (ix + 03)
	 ret       nz
	ld        a, (ix + p2_y)
	ld        (ix + 05), a
	ld        (ix + 03), $64
	ret

	ld        b, $02
	ld        c, $0B
	ld        a, $03
	add       a, (ix + 04)
	ld        l, a
	ld        a, $08
	push      ix
	ld        ix, $A058
	call      $96C7
	pop       ix
	ret
	ld        b, $02
	ld        c, $0B
	ld        a, $03
	add       a, (ix + 05)
	ld        l, a
	ld        a, 00
	push      ix
	ld        ix, $A058
	call      $96C7
	pop       ix
	ret

player1_hit:
	dec (ix + p1_hp)
	ld bc, $0000			; Top left coordinates 0, 0
	ld (penCol), bc			; Set coordinates
	ld a, (ix + p1_hp)			; Player 1's  lives
	bcall(_SetXXOP1)
	ld a, 02
	push ix
		bcall(_DispOP1A)
	pop ix
	ret

player2_hit:
	dec       (ix + p2_hp)
	ld        bc, $005B
	ld        (penCol), bc
	ld        a, (ix + p2_hp)
	bcall(_SetXXOP1)
	ld        a, 02
	push ix
		bcall(_DispOP1A)
	pop ix
	ret

	ld        bc, $0005
	ld        (penCol), bc
	ld        hl, $A025
	rst       28h				; bcall
	ld        h, c
	ld        b, l
	jr        +_
	ld        bc, $0042
	ld        (penCol), bc
	ld        hl, $A02C
	rst       28h				; bcall
	ld        h, c
	ld        b, l
	jr        +_

; Draw player1's ship
	ld b, 08
	ld a, 00
	ld l, (ix + p1_y)
	push ix
		ld ix, player1_sprite
		call ionPutSprite		; [ion.inc] ix = sprite, a = x, l = y, b = sprite height
	pop ix
; Draw player2's ship
	ld b, $08
	ld a, $58
	ld l, (ix + p2_y)
	push ix
		ld ix, player2_sprite
		call ionPutSprite
	pop ix
	ret

; delay
;  - repeat loop 50000 times
delay:
	ld hl, 50000		; # times to loop
delay_loop:
	dec hl
	ld a, h				; Check if HL == 0
	or l
	 jr nz, delay_loop	; Repeat if HL isn't 0 yet
	ret

clear_key_port:
	ld        a, $FF
	out       (01), a
	ret

_:
	call      $9FD9
	call      $96CD
_:
	rst       28h				; bcall
	ld        (hl), d
	ld        c, c
	cp        09
	jr        nz, -_
	ret

title_txt:
.db "Cannon War", 0

winner1_txt:
.db "WINNER", 0

winner2_txt:
.db "WINNER", 0

email1_txt:
.db "jgrucza@", 0

email2_txt:
.db "hotmail.com", 0

player1_sprite:
	.db %11000000
	.db %11100011
	.db %11100010
	.db %11111110
	.db %11111110
	.db %11100010
	.db %11100011
	.db %11000000

player2_sprite:
	.db %00000011
	.db %11000111
	.db %01000111
	.db %01111111
	.db %01111111
	.db %01000111
	.db %11000111
	.db %00000011

	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
long_bar_sprite:
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111, %11111111
	.db %11111111
label_a079:
	.db %11111111 ; rst       38h
