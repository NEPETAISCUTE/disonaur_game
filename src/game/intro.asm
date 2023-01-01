    INCLUDE "hardware.inc"

    SECTION "introData", ROM0
    title:
        db $15, $1A, $24, $20, $1F, $12, $26, $23, $00, $18, $12, $1E, $16 ;disonaur game
    TITLESIZE = @ - title
    start:
        db $21, $23, $16, $24, $24, $00, $24, $25, $12, $23, $25 ;press start
    STARTSIZE = @ - start

    TITLEPOS = _SCRN0 + (4 * SCRN_VX_B) + SCRN_VX_B/4-(TITLESIZE/2)+1

    STARTPOS = _SCRN0 + ($0B * SCRN_VX_B) + 4
    TEXTTIMING = 60

    GROUNDPOS = _SCRN0 + (14 * SCRN_VX_B)
    UNDERGROUNDPOS = GROUNDPOS + SCRN_VX_B ;the y of the ground + 1

    SECTION "introRAM", WRAM0
    firstIntroFrame:: ds 1
    introFrameCnt:: ds 1
    SECTION "intro", ROM0
    intro::
        ld a, [firstIntroFrame]
        cp 0
        jr nz, .endCpy

        call LCDOff

        ld de, title
        ld hl, TITLEPOS
        ld c, TITLESIZE
        call Memcpy

        ld a, $01
        ld hl, GROUNDPOS
        ld bc, SCRN_X_B
        call Memset

        ld d, $02
        ld hl, UNDERGROUNDPOS
        ld e, 12
    .groundLoop:
        ld a, d
        ld bc, SCRN_X_B
        call Memset
        ld a, d
        ld d, 0
        add hl, de
        ld d, a
        ld a, $40
        cp l
        jr nz, .groundLoop

        ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
        ld [rLCDC], a

        ld a, 1
        ld [firstIntroFrame], a

    .endCpy:
        ld a, [introFrameCnt]
        cp TEXTTIMING/2
        jr z, .drawPStart
        cp TEXTTIMING
        jr nz, .endDraw

        ld e, 0
        ld hl, STARTPOS
        ld c, STARTSIZE
        call LCDMemsetSmall
        ld a, -1
        ld [introFrameCnt], a
        jr .endDraw

    .drawPStart
        ld de, start
        ld hl, STARTPOS
        ld c, STARTSIZE
        call LCDMemcpySmall
    .endDraw
        ld hl, introFrameCnt
        inc [hl]

        ld a, $78
        ld [OAMMem], a
        ld a, $50
        ld [OAMMem+1], a
        ld a, $10
        ld [OAMMem+2], a
        ret
