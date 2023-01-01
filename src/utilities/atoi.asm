INCLUDE "hardware.inc"

SECTION "atoiRAM", WRAM0
bakladress: ds 1
bakvalue: ds 1
length: ds 1

SECTION "atoi", ROM0
;a = number
;bc = address of buffer

;c = length
atoi::
    ld [bakvalue], a
    ld a, c
    ld [bakladress], a
    ld a, [bakvalue]
    ld c, 0
.lenloop:
    ld d, 10
    call Div8
    ld a, d
    inc c
    cp a, 0
    jr nz, .lenloop

    ld a, c
    ld [length], a
    ld a, [bakladress]
    add a, c
    ld c, a

    jr nc, .skipCarry
    inc b
.skipCarry
    ld a, [bakvalue]

.copyLoop:
    dec bc
    ld d, 10
    call Div8
    add a, $1E
    ld [bc], a
    ld a, d
    cp a, 0
    jr nz, .copyLoop
.End
    ld h, b
    ld l, c
    ld d, 0
    ld a, [length]
    ld e, a
    add hl, de
    sub a, 3
    jr z, .zfSkip
.zfLoop:
    ld [hl], 0
    inc hl
    inc a
    jr nz, .zfLoop
.zfSkip
    ld a, [length]
    ld c, a
    ret