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
	set textWrite, (iy + sGrFlags)

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
	ld (ix + p1_timer), 0		; Player1's laser timer
	ld (ix + p2_timer), 0		; Player2's laser timer
	ld (ix + p1_laser_y), 8		; Player1's laser Y position
	ld (ix + p2_laser_y), 56	; Player2's laser Y position
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

; The main loop has three parts:
; 1. Read keys and react to key presses (moving ships and initiating laser fire)
; 2. Draw ship sprites to gbuf, copy to LCD, then erase ship sprites
; 3. Handle lasers (timers, collisions with ships, drawing) and player lives
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
	bit d2nd_bit, a				; Check if [2nd] was pressed
	push af						;
		call z, move_up_p1		; If so, move p1 up
	pop af						;
	bit 0, a					; [Graph]
	push af						;
		call z, fire_shot_p2	; Player2 fire
	pop af						;

	call clear_key_port			;
	ld a, Group2				; Group2 (contains alpha)
	out (01), a					;
	in a, (01)					;
	cp dAlpha					; Check if [Alpha] was pressed
	push af						;
		call z, move_down_p1	; If so, move p1 down
	pop af						;

	call clear_key_port			;
	ld a, Group7				; Arrow keys
	out (01), a					;
	in a, (01)					;
	cp dDown					; Check if [Down] was pressed
	push af						; 
		call z, move_down_p2	; If so, move p2 down
	pop af						;
	cp dUp						; Check if [Up] was pressed
	push af						;
		call z, move_up_p2		; If so, move p2 up
	pop af						;

	call clear_key_port			;
	ld a, Group6				; Clear
	out (01), a					;
	in a, (01)					;
	cp dClear					; Check if [Clear] was pressed
	 jp z, quit					; If so, quit game

; Update screen
	call xor_ship_sprites		; Show sprites to screen
	call ionFastCopy			; Copy graph buffer to LCD
	call xor_ship_sprites		; Erase sprites from screen (XOR same values erases them)

; Check if laser was fired
	ld a, -100					; Check if timer = 100
	add a, (ix + p1_timer)		; If timer = 100, a shot was fired
	 jr nz, clear_laser1		; Skip if laser wasn't fired
; Laser 1 was fired
	call draw_laser_p1			; Draw laser sprite

; Check laser collision with player 2:
; 	top of laser - 8 < shipY < bottom of laser
; If ship's Y coordinate is between (laser - 8) and (laser + 1), then it was a hit.
; Subtracting 8 from the top of the laser is the same as adding 8 to the ship's
; coordinates, so there are two equations here:
; 1. ship Y + 8 > laser Y 		== Bottom of the ship must be > top of the laser
; 2. ship Y 	< laser Y + 1	== Top of the ship must be < bottom of the laser

	ld a, (ix + p1_laser_y)		; This is the Y position of the ship when it was fired
	add a, LASER_OFF - 8		; Find bottom of laser beam and move up 8 pixels
	cp (ix + p2_y)				; If ship2 Y <= (laser Y - 8), aka (shipY + 8) <= laserY
	 jr nc, clear_laser1		; .. if so, bottom of the ship is above the laser, so
								; .. no collision is possible
	ld a, (ix + p1_laser_y)		; Reload unoffset laser Y
	add a, LASER_OFF + 1		; Find bottom of laser (laser is two pixels tall)
	cp (ix + p2_y)				; Check if ship2 Y > laser bottom
	 jr c, clear_laser1			; .. if so, the top of the ship is below the laser, so
								; .. no collision is possible
	call player2_hit			; Player was hit
clear_laser1:
	ld a, -96					; Check if timer is 96
	add a, (ix + p1_timer)		; 
	 jr nz, laser2_collision	; 
	call draw_laser_p1			; Erase the sprite

; Same basic behavior as above
laser2_collision:
	ld a, -100
	add a, (ix + p2_timer)
	 jr nz, clear_laser2
; Laser 2 was fired
	call draw_laser_p2
; Check collision with player 1 (ship bottom should be below laser,
;								 ship top should be above laser)
; If bottom of player 1 is above laser Y, no collision
	ld a, (ix + p2_laser_y)
	add a, LASER_OFF - 8
	cp (ix + p1_y)
	 jr nc, clear_laser2
; If top of player 1 is below laser Y, no collision
	ld a, (ix + p2_laser_y)
	add a, LASER_OFF + 1
	cp (ix + p1_y)
	 jr c, clear_laser2
	call player1_hit
clear_laser2:
	ld a, -96					; Check if 4 frames have passed (timer is set to 100
	add a, (ix + p2_timer)		; .. when laser is fired)
	 jr nz, dec_timer_p1		; Skip call to erase laser if the timer isn't 96
	call draw_laser_p2			; On frame 4, laser is done so erase the sprite
dec_timer_p1:
	ld a, 0						; Check if timer = 0
	add a, (ix + p1_timer)		;
	 jr z, dec_timer_p2			; Don't dec timer if already at 0
	dec (ix + p1_timer)			; Decrease timer
dec_timer_p2:
	ld a, 0						; Same as above for p2 timer
	add a, (ix + p2_timer)
	 jr z, check_health
	dec (ix + p2_timer)
check_health:
	ld a, 0						; Check if player1's health is down to 0
	add a, (ix + p1_hp)			;
	 jp z, player2_wins			; If so, player 2 wins
	ld a, 0						; Repeat for Player 2's health
	add a, (ix + p2_hp)			;
	 jp z, player1_wins			;
	jp main_loop				; End of main lop

move_up_p1:
	ld a, -8					; Check if player is at top of screen
	add a, (ix + p1_y)			; If Y = 8, literally: -8 + Y
	 ret z						; Quit if Y = 8
	dec (ix + p1_y)				; Otherwise, move player up one pixel
	ret							;

move_down_p1:
	ld a, -56					; Lowest Y position for player is 56 (sprite is 8 pixels)
	add a, (ix + p1_y)			; -56 + Y will set z flag if Y = 56
	 ret z						; Quit if Y = 56
	inc (ix + p1_y)				; Otherwise, move player down one pixel
	ret							;

fire_shot_p1:
	ld a, 0						; Check if counter is at 0
	add a, (ix + p1_timer)		; Set z flag if laser counter = 0
	 ret nz						; Quit if the timer hasn't reached 0
	ld a, (ix + p1_y)			; A = player's Y position
	ld (ix + p1_laser_y), a		; Load laser at player's Y position
	ld (ix + p1_timer), 100		; Reset timer
	ret							;

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
	ld b, LASER_H				; Height = 2
	ld c, 11					; Width = 11 (88 pixels, covers everything but P1's ship)
	ld a, LASER_OFF				; Add offset to the Y position so that it is drawn in the
	add a, (ix + p1_laser_y)	; .. center of the ship sprite
	ld l, a						; Y position
	ld a, 8						; X position
	push ix						; > Save IX (variable pointer)
		ld ix, laser_sprite		;  Sprite to draw
		call ionLargeSprite		;  ionLargeSprite
	pop ix						; < Restore IX
	ret

; Mostly the same as [draw_laser_p1] above
draw_laser_p2:
	ld b, LASER_H
	ld c, 11
	ld a, LASER_OFF
	add a, (ix + p2_laser_y)
	ld l, a
	ld a, 0						; Drawn from the left, so this draws over P1's sprite
	push ix
		ld ix, laser_sprite
		call ionLargeSprite		; ionLargeSprite
	pop ix
	ret

; Decreases player 1's HP and updates the text at the top
player1_hit:
	dec (ix + p1_hp)			; Decrease player 1's HP
	ld bc, $0000				; Top left coordinates 0, 0
	ld (penCol), bc				; Set coordinates
	ld a, (ix + p1_hp)			; Player 1's  lives
	bcall(_SetXXOP1)			; Stores a into OP1 (a floating point "register", just
								; .. a value in RAM TI uses for FP calculations)
	ld a, 02					; Print a max of 2 characters
	push ix						; > Save IX (holds our variables)
		bcall(_DispOP1A)		;  Prints OP1 (p1's HP) to the screen using small font
	pop ix						; < Restore IX
	ret

; Same as [player1_hit] above, just printed in a different spot
player2_hit:
	dec (ix + p2_hp)
	ld bc, $005B
	ld (penCol), bc
	ld a, (ix + p2_hp)
	bcall(_SetXXOP1)
	ld a, 02
	push ix
		bcall(_DispOP1A)
	pop ix
	ret

player1_wins:
	ld bc, $0005				; X = 5, Y = 0
	ld (penCol), bc				; [penRow] follows [penCol] in memory
	ld hl, winner1_txt
	bcall(_VPutS)
	jr quit

player2_wins:
	ld bc, $0042				; Same as above, but drawn at a different location
	ld (penCol), bc
	ld hl, winner2_txt
	bcall(_VPutS)
	jr quit

xor_ship_sprites:
; Draw player1's ship
	ld b, 8
	ld a, 0
	ld l, (ix + p1_y)
	push ix
		ld ix, player1_sprite
		call ionPutSprite		; [ion.inc] ix = sprite, a = x, l = y, b = sprite height
	pop ix
; Draw player2's ship
	ld b, 8						; Sprite height
	ld a, 88					; X, 96 - 8 (screen width = 96)
	ld l, (ix + p2_y)			; Y
	push ix
		ld ix, player2_sprite	; Sprite to draw
		call ionPutSprite		; [ion.inc] ix = sprite, a = x, l = y, b = sprite height
	pop ix
	ret

; delay
;  - repeat loop 50000 times
delay:
	ld hl, 50000				; # times to loop
delay_loop:
	dec hl
	ld a, h						; Check if HL == 0
	or l
	 jr nz, delay_loop			; Repeat if HL isn't 0 yet
	ret

clear_key_port:
	ld a, $FF					; Disable all key groups
	out (01), a					; Send value to key port
	ret

quit:
	call xor_ship_sprites		; Erase ship sprites
	call ionFastCopy			; Copy gbuf to LCD
exit_clear_loop:
	bcall(_getkey)				; Wait for a key (if you pressed [Clear] to quit, _getkey
								; .. will read it immediately and quit without waiting)
	cp kClear					; Check if [Clear] was pressed (GetKey key code)
	 jr nz, exit_clear_loop		; Loop until [Clear] is pressed
	ret							; ~~THE END~~

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
	.db %11111111, %11111111
