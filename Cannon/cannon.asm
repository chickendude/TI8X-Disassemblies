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

; Equates
LASER_OFF	equ 3				; Y offset of the laser from the top of the player's ship
LASER_H		equ 2				; Height of the laser sprite

; Variables
p1_y = 0
p2_y = 1
p1_timer = 2
p2_timer = 3
p1_laser_y = 4
p2_laser_y = 5
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
	ld (ix + p1_y), 8			; Player1's starting Y position
	ld (ix + p2_y), 56			; Player2's starting Y position
	ld (ix + p1_timer), $00		; Player1's laser timer
	ld (ix + p2_timer), $00		; Player2's laser timer
	ld (ix + p1_laser_y), $08	; Player1's laser Y position
	ld (ix + p2_laser_y), $38	; Player2's laser Y position
	ld (ix + p1_hp), 10 		; Player1 lives (starts at 10, but we dec 1 when 
								; .. displaying in [player1_hit])
	ld (ix + p2_hp), 10 		; Player2 lives

	ld bc, $001D				; y = 0, x = 29
	ld (penCol), bc				; Store (pen/small) text coordinates
	ld hl, title_txt			; Address of text to draw
	bcall(_VPutS)				; Draw small text
	ld b, 1						; Height
	ld c, 12					; Width
	ld l, 7						; Y=7
	ld a, 0						; X=0
	push ix						; > IX holds our variable data
		ld ix, long_bar_sprite	;  IX = sprite to draw
		call ionLargeSprite		;  Draw the line underneath the title/score
	pop ix						; < Restore variable data
	call player1_hit			; Subtracts life from player and draws new value to screen
	call player2_hit			; Same as above for player 2

main_loop:
; Check keys
	call clear_key_port
	ld a, Group1				; Group1: [Y=]->[Graph] and [2nd]/[Mode]/[Del]
	out (01), a					; Set group of keys to read (port 01 = key port)
	in a, (01)					; Read keys pressed in Group1 into a
	bit dYEqu_bit, a			; [Y=]
	push af						; > Save keys pressed
		call z, fire_shot_p1	;  Player1 fire
	pop af						; < Restore keys pressed back into a
	bit d2nd_bit, a				; [2nd]
	push af
		call z, move_up_p1
	pop af
	bit 0, a					; [Graph]
	push af
		call z, fire_shot_p2	; Player2 fire
	pop af

	call clear_key_port
	ld a, Group2				; Group2 (contains alpha)
	out (01), a
	in a, (01)
	cp dAlpha					; Check if [Alpha] was pressed
	push af
		call z, move_down_p1
	pop af

	call clear_key_port
	ld a, Group7				; Arrow keys
	out (01), a
	in a, (01)
	cp dDown					; Check if [Down] was pressed
	push af						; 
		call z, move_down_p2	; If so, move p2 down
	pop af						;
	cp dUp						; Check if [Up] was pressed
	push af						;
		call z, move_up_p2		; If so, move p2 up
	pop af						;

	call clear_key_port
	ld a, Group6				; Clear
	out (01), a
	in a, (01)
	cp dClear					; Check if [Clear] was pressed
	 jp z, quit					; If so, quit game

; Update screen
	call xor_ship_sprites		; Show sprites to screen
	call $96CD
	call xor_ship_sprites		; Erase sprites from screen (XOR same values erases them)
; Check if laser was fired
	ld a, -100					; Check if timer = 100
	add a, (ix + p1_timer)		; If timer = 100, a shot was fired
	 jr nz, clear_laser1		; Skip if laser wasn't fired
; Laser 1 was fired
	call draw_laser_p1			; Draw laser sprite
	ld a, (ix + p1_laser_y)		; This is the Y position of the ship when it was fired
	add a, -(LASER_OFF + LASER_H)	; Find bottom of laser beam
	cp (ix + p2_y)				; 
	 jr nc, clear_laser1
	ld a, (ix + p1_laser_y)
	add a, 04
	cp (ix + p2_y)
	 jr c, clear_laser1
	call $9FA1
clear_laser1:
	ld a, -96					; Check if timer is 96
	add a, (ix + p1_timer)		; 
	 jr nz, $9ebb				; 
	call $9F57
label_9ebb:
	ld        a, $9C
	add       a, (ix + p2_timer)
	jr        nz, +_
	call      $9F6F
	ld        a, (ix + p2_laser_y)
	add       a, $FB
	cp        (ix + p1_y)
	jr        nc, +_
	ld        a, (ix + p2_laser_y)
	add       a, 04
	cp        (ix + p1_y)
	jr        c, +_
	call      $9F87
_:
	ld        a, $A0
	add       a, (ix + p2_timer)
	jr        nz, +_
	call      $9F6F
_:
	ld        a, 00
	add       a, (ix + p1_timer)
	jr        z, +_
	dec       (ix + p1_timer)
_:
	ld        a, 00
	add       a, (ix + p2_timer)
	jr        z, +_
	dec       (ix + p2_timer)
_:
	ld        a, 00
	add       a, (ix + p1_hp)
	jp        z, player2_wins
	ld        a, 00
	add       a, (ix + p2_hp)
	 jp z, player1_wins
	jp main_loop

move_up_p1:
	ld a, -8					; Check if player is at top of screen
	add a, (ix + p1_y)			; If Y = 8, literally: -8 + Y
	 ret z						; Quit if Y = 8
	dec (ix + p1_y)				; Otherwise, move player up one pixel
	ret

move_down_p1:
	ld a, -56					; Lowest Y position for player is 56 (sprite is 8 pixels)
	add a, (ix + p1_y)			; -56 + Y will set z flag if Y = 56
	 ret z						; Quit if Y = 56
	inc (ix + p1_y)				; Otherwise, move player down one pixel
	ret

fire_shot_p1:
	ld a, 0						; Check if counter is at 0
	add a, (ix + p1_timer)		; Set z flag if laser counter = 0
	 ret nz						; Quit if the timer hasn't reached 0
	ld a, (ix + p1_y)			; A = player's Y position
	ld (ix + p1_laser_y), a				; Load laser at player's Y position
	ld (ix + p1_timer), 100		; Reset timer
	ret

; Same as [move_up_p1] above
move_up_p2:
	ld a, -8
	add a, (ix + p2_y)
	 ret z
	dec (ix + p2_y)
	ret

; Same as [move_down_p1] above
move_down_p2:
	ld a, -56
	add a, (ix + p2_y)
	 ret z
	inc (ix + p2_y)
	ret

; Same as [fire_shot_p1] above
fire_shot_p2:
	ld a, 0
	add a, (ix + p2_timer)
	 ret nz
	ld a, (ix + p2_y)
	ld (ix + p2_laser_y), a
	ld (ix + p2_timer), 100
	ret

draw_laser_p1:
	ld b, LASER_H			; Height = 2
	ld c, 11				; Width = 11 (88 pixels, so covers everything but P1's ship)
	ld a, LASER_OFF			; Add offset to the Y position so that it is drawn in the
	add a, (ix + p1_laser_y)	; .. center of the ship sprite
	ld l, a					; Y position
	ld a, 8					; X position
	push ix					; > Save IX (variable pointer)
		ld ix, laser_sprite	;  Sprite to draw
		call $96C7			;  ionLargeSprite
	pop ix					; < Restore IX
	ret

; Mostly the same as [draw_laser_p1] above
draw_laser_p2:
	ld b, LASER_H
	ld c, 11
	ld a, 3
	add a, (ix + p2_laser_y)
	ld l, a
	ld a, 0					; Drawn from the left, so this draws over P1's sprite
	push ix
		ld ix, $A058
		call $96C7			; ionLargeSprite
	pop ix
	ret

player1_hit:
	dec (ix + p1_hp)
	ld bc, $0000				; Top left coordinates 0, 0
	ld (penCol), bc				; Set coordinates
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

player1_wins:
	ld bc, $0005			; X = 5, Y = 0
	ld (penCol), bc			; [penRow] follows [penCol] in memory
	ld hl, winner1_txt
	bcall(_VPutS)
	jr quit

player2_wins:
	ld bc, $0042
	ld (penCol), bc
	ld hl, winner2_txt
	bcall(_VPutS)
	jr quit

xor_ship_sprites:
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

quit:
	call      xor_ship_sprites
	call      $96CD
exit_clear_loop:
	bcall(_getkey)
	cp kClear					; Check if [Clear] was pressed (GetKey key code)
	 jr nz, exit_clear_loop
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

laser_sprite:
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
