INCLUDE "hardware.inc"

SECTION "MainGameRAM", WRAM0

SECTION "MainGame", ROM0
game::
    ld a, [firstStateFrame]
    cp a, 0
    jr nz, .skipFirstFrameLoading

    call LCDOff
    
    ld a, 0
    ld hl, _SCRN0
    ld bc, SCRN_VX_B * SCRN_VY_B
    call Memset

    ld a, 1
    ld [firstStateFrame], a

    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ld [rLCDC], a

.skipFirstFrameLoading
    ret