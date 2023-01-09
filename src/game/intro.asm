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
introFrameCnt:: ds 1
SECTION "intro", ROM0
;intro screen routine
;called only when the game state is set to GSTATE_INTRO
;called in main.asm, function main
intro::
    ld a, [firstStateFrame]
    and a
    jr nz, .endFrameSetup

    call initFrame

.endFrameSetup:
    
    call handleBlinkingText

    ld hl, introFrameCnt
    inc [hl]

    ld a, [new_keys]
    and PADF_START
    jr z, .leave
    
    ld a, GSTATE_GAME
    ld [gamestate], a
    ld a, 0
    ld [firstStateFrame], a
    
    ld a, [mainFrameCnt]
    call srand

    jr .leave
.leave
    ret


;takes care of setting up the display on the first frame, basically prepares tiles that needs to be there right away in order to simplify next rendering frames
initFrame:
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

    ld a, $78
    ld [playerY], a
    ld a, $50
    ld [playerX], a
    ld a, $11
    ld [playerTile], a

    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ld a, 0
    ld [backgroundX], a

    ld a, 1
    ld [firstStateFrame], a

;takes care of making the "PRESS START" text blink, nothing crazy
handleBlinkingText:
    ld a, [introFrameCnt]
    cp TEXTTIMING/2
    jr z, .drawPStart
    cp TEXTTIMING
    jr nz, .endDraw

    ld e, 0
    ld hl, STARTPOS
    ld c, STARTSIZE
    call LCDMemset
    ld a, -1
    ld [introFrameCnt], a
    jr .endDraw
.drawPStart:
    ld de, start
    ld hl, STARTPOS
    ld c, STARTSIZE
    call LCDMemcpy
.endDraw:
    ret