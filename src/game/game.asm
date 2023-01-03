INCLUDE "hardware.inc"

SECTION "MainGameRAM", WRAM0
animFrameCnt:: ds 1
SECTION "MainGame", ROM0
game::
    ld a, [firstStateFrame]
    cp a, 0
    jr nz, .skipFirstFrameLoading

    call initFrame

.skipFirstFrameLoading:

    ld a, [animFrameCnt]
    cp 6
    jr nz, .skipAnimCnt
    ld a, 0
    ld [animFrameCnt], a
    ld hl, OAMMem+2
    inc [hl]
    ld a, 4
    cp [hl]
    jr nz, .skipAnimCnt
    ld a, 1
    ld [hl], a
.skipAnimCnt:
    ld hl, animFrameCnt
    inc [hl]
    ret


initFrame:
    call LCDOff
    
    ld a, 0
    ld hl, _SCRN0
    ld bc, SCRN_VX_B * (SCRN_Y_B-4)
    call Memset

    ld a, 1
    ld hl, _SCRN0 + (SCRN_VX_B * $0E) + $14
    ld bc, $20 - $14
    call Memset

    ld a, 2
    ld hl, _SCRN0 + (SCRN_VX_B * $0F) + $14
    ld bc, $20 - $14
    call Memset

    ld a, 2
    ld hl, _SCRN0 + (SCRN_VX_B * $10) + $14
    ld bc, $20 - $14
    call Memset

    ld a, 2
    ld hl, _SCRN0 + (SCRN_VX_B * $11) + $14
    ld bc, $20 - $14
    call Memset


    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

    ld a, 1
    ld [OAMMem+2], a

    ld [firstStateFrame], a
    ret