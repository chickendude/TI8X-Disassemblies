.nolist
#include "../inc/ti83plus.inc"
#include "../inc/ion.inc"
.list

.db t2ByteTok, tasmCmp
.org $9D95

; Ion header
    ret
    jr        nc, start
	.db "Cannon War 1.0",0

; Program start
start:
    set       7, (iy + $14)
    ld        bc, $0302
    ld        (curRow), bc
label_0067:
    ld        hl, $A01A
    rst       28h				; bcall
    ld        a, (bc)
    ld        b, l
    ld        bc, $0404
    ld        (curRow), bc
    ld        hl, $A033
label_0077:
    rst       28h				; bcall
    ld        a, (bc)
    ld        b, l
    ld        bc, $0305
    ld        (curRow), bc
    ld        hl, $A03C
    rst       28h				; bcall
    ld        a, (bc)
    ld        b, l
    call      $9FFE
    call      $9FFE
    call      $9FFE
    call      $9FFE
    call      $9FFE
    call      $9FFE
    call      $9FFE
    call      $9FFE
    ld        ix, $9872
    ld        (ix + 00), $08
    ld        (ix + 01), $38
    ld        (ix + 02), $00
    ld        (ix + 03), $00
    ld        (ix + 04), $08
    ld        (ix + 05), $38
    ld        (ix + 06), $0A
    ld        (ix + 07), $0A
    ld        bc, $001D
    ld        (penCol), bc
    ld        hl, $A01A
    rst       28h				; bcall
    ld        h, c
    ld        b, l
    ld        b, $01
    ld        c, $0C
    ld        l, $07
    ld        a, $00
    push      ix
    ld        ix, $A06E
    call      $96C7
    pop       ix
    call      $9F87
    call      $9FA1
    call      $A007
    ld        a, $BF
    out       (01), a
    in        a, (01)
    bit       4, a
    push      af
    call      z, $9F21
    pop       af
    bit       5, a
    push      af
    call      z, $9F0D
    pop       af
    bit       0, a
    push      af
    call      z, $9F46
    pop       af
    call      $A007
    ld        a, $DF
    out       (01), a
    in        a, (01)
    cp        $7F
    push      af
    call      z, $9F17
    pop       af
    call      $A007
    ld        a, $FE
    out       (01), a
    in        a, (01)
    cp        $FE
    push      af
    call      z, $9F3C
    pop       af
    cp        $F7
    push      af
    call      z, $9F32
    pop       af
    call      $A007
    ld        a, $FD
    out       (01), a
    in        a, (01)
    cp        $BF
    jp        z, $A00C
    call      $9FD9
    call      $96CD
    call      $9FD9
    ld        a, $9C
    add       a, (ix + 02)
    jr        nz, $9eb1
    call      $9F57
    ld        a, (ix + 04)
    add       a, $FB
    cp        (ix + 01)
    jr        nc, $9eb1
    ld        a, (ix + 04)
    add       a, 04
    cp        (ix + 01)
    jr        c, $9eb1
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
    cp        (ix + 00)
    jr        nc, +_
    ld        a, (ix + 05)
    add       a, 04
    cp        (ix + 00)
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
    add       a, (ix + 06)
    jp        z, $9FCA
    ld        a, 00
    add       a, (ix + 07)
    jp        z, $9FBB
    jp        $9E34
    ld        a, $F8
    add       a, (ix + 00)
    ret       z
    dec       (ix + 00)
    ret
    ld        a, $C8
    add       a, (ix + 00)
    ret       z
    inc       (ix + 00)
    ret
    ld        a, 00
    add       a, (ix + 02)
    ret       nz
    ld        a, (ix + 00)
    ld        (ix + 04), a
    ld        (ix + 02), $64
    ret
    ld        a, $F8
    add       a, (ix + 01)
    ret       z
    dec       (ix + 01)
    ret
    ld        a, $C8
    add       a, (ix + 01)
    ret       z
    inc       (ix + 01)
    ret
    ld        a, 00
    add       a, (ix + 03)
    ret       nz
    ld        a, (ix + 01)
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
    dec       (ix + 06)
    ld        bc, $0000
    ld        (penCol), bc
    ld        a, (ix + 06)
    rst       28h				; bcall
    adc       a, h
    ld        b, a
    ld        a, 02
    push      ix
    rst       28h				; bcall
    rst       30h
    ld        c, e
    pop       ix
    ret
    dec       (ix + 07)
    ld        bc, $005B
    ld        (penCol), bc
    ld        a, (ix + 07)
    rst       28h				; bcall
    adc       a, h
    ld        b, a
    ld        a, 02
    push      ix
    rst       28h				; bcall
    rst       30h
    ld        c, e
    pop       ix
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
    ld        b, 08
    ld        a, 00
    ld        l, (ix + 00)
    push      ix
    ld        ix, $A048
    call      $96C4
    pop       ix
    ld        b, $08
    ld        a, $58
    ld        l, (ix + 01)
    push      ix
    ld        ix, $A050
    call      $96C4
    pop       ix
    ret
label_9FFE:
    ld        hl, $C350
label_a001:
    dec       hl
    ld        a, h
    or        l
    jr        nz, $a001
    ret
label_a007:
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
    ld        b, e
    ld        h, c
    ld        l, (hl)
    ld        l, (hl)
    ld        l, a
    ld        l, (hl)
    jr        nz, $a079
    ld        h, c
    ld        (hl), d
    nop
    ld        d, a
    ld        c, c
    ld        c, (hl)
    ld        c, (hl)
    ld        b, l
    ld        d, d
    nop
    ld        d, a
    ld        c, c
    ld        c, (hl)
    ld        c, (hl)
    ld        b, l
    ld        d, d
    nop
    ld        l, d
    ld        h, a
    ld        (hl), d
    ld        (hl), l
    ld        h, e
    ld        a, d
    ld        h, c
    ld        b, b
    nop
    ld        l, b
    ld        l, a
    ld        (hl), h
    ld        l, l
    ld        h, c
    ld        l, c
    ld        l, h
    ld        l, $63
    ld        l, a
    ld        l, l
    nop
    ret       nz
    ex        (sp), hl
    jp        po, $FEFE
    jp        po, $C0E3
    inc       bc
    rst       00h
    ld        b, a
    ld        a, a
    ld        a, a
    ld        b, a
    rst       00h
    inc       bc
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
    rst       38h
label_a079:
    rst       38h
